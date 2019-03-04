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
  resolves = ["Deploy to Azure WebappContainer"]
}

action "Env is Test" {
  uses = "actions/bin/filter@master"
  args = "environment test"
}

action "Build Docker Image" {
  uses = "actions/docker/cli@master"
  needs = ["Env is Test"]
  args = "build -t octodemo.azurecr.io/mysampleexpressappazure:$GITHUB_SHA -t octodemo.azurecr.io/mysampleexpressappazure-$GITHUB_REF ."
}

action "Azure Login" {
  uses = "Azure/github-actions/login@master"
  needs = ["Build Docker Image"]
  env = {
    AZURE_SUBSCRIPTION = "PAYG - GitHub Billing"
  }
  secrets = ["AZURE_SERVICE_APP_ID", "AZURE_SERVICE_PASSWORD", "AZURE_SERVICE_TENANT"]
  args = "--name octodemo.azurecr.io"
}

action "Azure Regisitry Login" {
  uses = "actions/docker/login@master"
  needs = ["Azure Login"]
  env = {
    DOCKER_REGISTRY_URL = "octodemo.azurecr.io"
  }
  secrets = [
    "DOCKER_PASSWORD",
    "DOCKER_USERNAME",
  ]
}

action "Push Docker Image" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Azure Regisitry Login"]
  args = "push octodemo.azurecr.io/mysampleexpressappazure:$GITHUB_SHA"
}

action "Create Azure WebApp" {
  uses = "Azure/github-actions/cli@master"
  needs = ["Push Docker Image"]
  env = {
    RESOURCE_GROUP = "github-octodemo"
    APP_SERVICE_PLAN = "github-octodemo-app-service-plan"
    WEBAPP_NAME = "mysampleexpressapp-actions"
    CONTAINER_IMAGE_NAME = "mysampleexpressappazure:91c0e7457eba5eb31519f9eef42e26f52431eefe"
    AZURE_SCRIPT = "az webapp create --resource-group $RESOURCE_GROUP --plan $APP_SERVICE_PLAN --name $WEBAPP_NAME --deployment-container-image-name $CONTAINER_IMAGE_NAME --output json > $HOME/azure_webapp_creation.json"
  }
}

action "Deploy to Azure WebappContainer" {
  uses = "Azure/github-actions/containerwebapp@master"
  secrets = [
    "DOCKER_PASSWORD",
    "DOCKER_USERNAME",
  ]
  needs = ["Create Azure WebApp"]
  env = {
    AZURE_APP_NAME = "mysampleexpressapp-actions"
    DOCKER_REGISTRY_URL = "octodemo.azurecr.io"
    CONTAINER_IMAGE_NAME = "octodemo.azurecr.io/mysampleexpressappazure"
    CONTAINER_IMAGE_TAG = "$GITHUB_SHA"
  }
}
