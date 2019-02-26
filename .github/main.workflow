workflow "Continuous Integration" {
  on = "push"
  resolves = ["Test"]
}

action "Install" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "install"
}

action "Test" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  needs = ["Install"]
  args = "test"
}

workflow "Deploy to Test" {
  on = "deployment"
  resolves = ["Grab Zeit Deployment Id"]
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

workflow "Deploy to Staging" {
  on = "deployment"
  resolves = [
    "Deploy to Zeit Staging",
  ]
}

action "Staging Deployment" {
  uses = "actions/bin/filter@master"
  args = "environment staging"
}

action "Deploy to Zeit Staging" {
  uses = "actions/zeit-now@master"
  needs = ["Staging Deployment"]
  args = "--public -n mysampleexpressapp-staging"
  secrets = ["ZEIT_TOKEN"]
}

workflow "Deploy to Production" {
  on = "deployment"
  resolves = [
    "Deploy to Zeit Production",
  ]
}

action "Production Deployment" {
  uses = "actions/bin/filter@master"
  args = "environment production"
}

action "Deploy to Zeit Production" {
  uses = "actions/zeit-now@master"
  needs = ["Production Deployment"]
  args = "--public -n mysampleexpressapp-production"
  secrets = ["ZEIT_TOKEN"]
}

action "Grab Zeit Deployment Id" {
  uses = "./actions/GrabZeitDeployment"
  needs = ["Deploy to Zeit Test"]
  args = "/github/home/zeit-test.out"
  cmd = "cat /github/workflow/event.json"
}
