workflow "Continuous Integration" {
  on = "push"
  resolves = ["Test"]
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

workflow "Deploy to Test" {
  on = "deployment"
  resolves = ["Update Deploy Status for Test"]
}

action "Test Deployment" {
  uses = "actions/bin/filter@master"
  args = "environment test"
}

action "Deploy to Zeit Test" {
  uses = "actions/zeit-now@master"
  needs = ["Test Deployment"]
  secrets = ["ZEIT_TOKEN"]
  args = "--public -n mysampleexpressapp-test -m PR=$GITHUB_REF > $HOME/zeit-test.out"
}

action "Update Deploy Status for Test" {
  uses = "./actions/DeployStatusUpdateAction"
  needs = ["Deploy to Zeit Test"]
  secrets = ["GITHUB_TOKEN"]
  args = "cat /github/home/zeit-test.out"
}


workflow "Deploy to Staging" {
  on = "deployment"
  resolves = [
    "Update Deploy Status for Staging",
  ]
}

action "Staging Deployment" {
  uses = "actions/bin/filter@master"
  args = "environment staging"
}

action "Deploy to Zeit Staging" {
  uses = "actions/zeit-now@master"
  needs = ["Staging Deployment"]
  args = "--public -n mysampleexpressapp-staging -m PR=$GITHUB_REF > $HOME/zeit-staging.out"
  secrets = ["ZEIT_TOKEN"]
}

action "Update Deploy Status for Staging" {
  uses = "./actions/DeployStatusUpdateAction"
  needs = ["Deploy to Zeit Staging"]
  secrets = ["GITHUB_TOKEN"]
  args = "cat /github/home/zeit-staging.out"
}

workflow "Deploy to Production" {
  on = "deployment"
  resolves = [
    "Clean up Zeit Production"
  ]
}

action "Production Deployment" {
  uses = "actions/bin/filter@master"
  args = "environment production"
}

action "Deploy to Zeit Production" {
  uses = "actions/zeit-now@master"
  needs = ["Production Deployment"]
  args = "--public -n mysampleexpressapp-production -m PR=$GITHUB_REF > $HOME/zeit-production.out"
  secrets = ["ZEIT_TOKEN"]
}

action "Alias Zeit Production" {
  needs = ["Deploy to Zeit Production"]
  uses = "actions/zeit-now@master"
  args = "alias `cat $HOME/zeit-production.out` https://mysampleexpressapp-prod.now.sh"
  secrets = ["ZEIT_TOKEN"]
}

action "Update Deploy Status for Production" {
  uses = "./actions/DeployStatusUpdateAction"
  needs = ["Alias Zeit Production"]
  secrets = ["GITHUB_TOKEN"]
  args = "echo 'https://mysampleexpressapp-prod.now.sh'"
}

action "Clean up Zeit Production" {
  needs = ["Update Deploy Status for Production"]
  uses = "actions/zeit-now@master"
  args = "rm mysampleexpressapp-production --safe --yes"
  secrets = ["ZEIT_TOKEN"]
}
