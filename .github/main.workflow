workflow "Continuous Integration" {
  on = "push"
  resolves = [
    "Test",
    "GitHub Action for Docker",
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
  resolves = ["Azure Login"]
}

action "Env is Test" {
  uses = "actions/bin/filter@master"
  args = "environment test"
}

action "Build Docker Image" {
  uses = "actions/docker/cli@master"
  args = "build -t octodemo.azurecr.io/mysampleexpressappazure:$GITHUB_SHA -t octodemo.azurecr.io/mysampleexpressappazure-$GITHUB_REF ."
}

action "Azure Login" {
  uses = "Azure/github-actions/login@master"
  needs = ["Build Docker Image"]
  env = {
    AZURE_SUBSCRIPTION = "PAYG - GitHub Billing"
  }
  secrets = ["AZURE_SERVICE_APP_ID", "AZURE_SERVICE_PASSWORD", "AZURE_SERVICE_TENANT"]
}

action "GitHub Action for Docker" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Azure Login"]
  args = "push octodemo.azurecr.io/mysampleexpressappazure:$GITHUB_SHA"
}
