workflow "Continuous Integration" {
  on = "push"
  resolves = [
    "Test",
  ]
}

action "Install" {
  uses = "actions/npm@master"
  args = "install"
}

action "Test" {
  uses = "actions/npm@master"
  needs = ["Install"]
  args = "test"
}

workflow "Documentation" {
  on = "push"
  resolves = ["Generate doc"]
}

action "Filter for Doc generation" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Generate doc" {
  uses = "helaili/jekyll-action@master"
  needs = ["Filter for Doc generation"]
  secrets = ["JEKYLL_PAT"]
}

workflow "Deploy to Test" {
  on = "deployment"
  resolves = ["Update deployment status"]
}

action "Env is Test" {
  uses = "actions/bin/filter@master"
  args = "environment test"
}

action "Azure Login" {
  uses = "Azure/github-actions/login@master"
  needs = ["Env is Test"]
  env = {
    AZURE_SUBSCRIPTION = "PAYG - GitHub Billing"
  }
  secrets = ["AZURE_SERVICE_APP_ID", "AZURE_SERVICE_PASSWORD", "AZURE_SERVICE_TENANT"]
  args = "--name octodemo.azurecr.io"
}

action "Azure Registry Login" {
  uses = "actions/docker/login@master"
  needs = ["Env is Test"]
  env = {
    DOCKER_REGISTRY_URL = "octodemo.azurecr.io"
  }
  secrets = [
    "DOCKER_PASSWORD",
    "DOCKER_USERNAME",
  ]
}

action "Build Docker Image" {
  uses = "actions/docker/cli@master"
  needs = ["Env is Test"]
  args = "build -t octodemo.azurecr.io/mysampleexpressappazure:$GITHUB_SHA -t octodemo.azurecr.io/mysampleexpressappazure-$GITHUB_REF ."
}

action "Push Docker Image" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Build Docker Image", "Azure Registry Login"]
  args = "push octodemo.azurecr.io/mysampleexpressappazure:$GITHUB_SHA"
}

action "Create Azure WebApp" {
  uses = "Azure/github-actions/cli@master"
  needs = ["Azure Login"]
  env = {
    RESOURCE_GROUP = "github-octodemo"
    APP_SERVICE_PLAN = "github-octodemo-app-service-plan"
    WEBAPP_NAME = "mysampleexpressapp-actions"
    CONTAINER_IMAGE_NAME = "octodemo.azurecr.io/mysampleexpressappazure"
    AZURE_SCRIPT = "az webapp create --resource-group $RESOURCE_GROUP --plan $APP_SERVICE_PLAN --name $WEBAPP_NAME-${GITHUB_SHA:0:7} --deployment-container-image-name $CONTAINER_IMAGE_NAME:$GITHUB_SHA --output json > $HOME/azure_webapp_creation.json"
  }
}

action "Deploy to Azure WebappContainer" {
  uses = "Azure/github-actions/cli@master"
  secrets = [
    "DOCKER_PASSWORD",
    "DOCKER_USERNAME",
    "AZURE_SUBSCRIPTION_ID",
  ]
  needs = ["Create Azure WebApp", "Push Docker Image"]
  env = {
    RESOURCE_GROUP = "github-octodemo"
    WEBAPP_NAME = "mysampleexpressapp-actions"
    CONTAINER_IMAGE_NAME = "octodemo.azurecr.io/mysampleexpressappazure"
    DOCKER_REGISTRY_URL = "https://octodemo.azurecr.io"
    AZURE_SCRIPT = "az webapp config container set --docker-custom-image-name $CONTAINER_IMAGE_NAME:$GITHUB_SHA --docker-registry-server-url $DOCKER_REGISTRY_URL --docker-registry-server-password $DOCKER_PASSWORD --docker-registry-server-user $DOCKER_USERNAME --name $WEBAPP_NAME-${GITHUB_SHA:0:7} --resource-group $RESOURCE_GROUP --subscription $AZURE_SUBSCRIPTION_ID"
  }
}

action "Set Webapp Tags" {
  uses = "Azure/github-actions/cli@master"
  secrets = [
    "AZURE_SUBSCRIPTION_ID",
  ]
  needs = ["Create Azure WebApp"]
  env = {
    RESOURCE_GROUP = "github-octodemo"
    WEBAPP_NAME = "mysampleexpressapp-actions"
    AZURE_SCRIPT = "BRANCH=$(jq -r '.deployment.ref' $GITHUB_EVENT_PATH) && az webapp update -g $RESOURCE_GROUP -n $WEBAPP_NAME-${GITHUB_SHA:0:7} --set tags.branch=$BRANCH"
  }
}

action "Update deployment status" {
  uses = "./actions/DeployStatusUpdateAction"
  needs = ["Deploy to Azure WebappContainer", "Push Docker Image", "Set Webapp Tags"]
  secrets = ["GITHUB_TOKEN"]
  args = "jq -r '\"https://\\(.defaultHostName)\"' $HOME/azure_webapp_creation.json"
}

workflow "Clean up" {
  on = "pull_request"
  resolves = [
    "Debug",
    "Debug Deployments",
  ]
}

action "Debug" {
  uses = "hmarr/debug-action@master"
}

action "Filter closed PRs" {
  uses = "actions/bin/filter@master"
  args = "action closed"
}

action "Deployments" {
  uses = "swinton/httpie.action@master"
  needs = ["Filter closed PRs"]
  args = ["--auth-type=jwt", "--auth=$GITHUB_TOKEN", "POST", "api.github.com/repos/$GITHUB_REPOSITORY/deployments", "ref=$(echo $GITHUB_REF  | sed -r 's/refs\\/heads\\/(.*)/\\1/')"]
  secrets = ["GITHUB_TOKEN"]
}

action "Debug Deployments" {
  uses = "helaili/debug-action@master"
  needs = ["Deployments"]
  args = "$HOME/Deployments.response.body"
}
