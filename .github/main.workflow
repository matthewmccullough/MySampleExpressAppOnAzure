workflow "Continuous Integration" {
  on = "push"
  resolves = ["Test"]
}

action "Install" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  runs = "npm install"
}

action "Test" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  needs = ["Install"]
  runs = "npm test"
}

workflow "Deploy" {
  on = "deployment"
  resolves = [
    "Deploy to Zeit Production",
    "Deploy to Zeit Staging",
    "Deploy to Zeit Test",
  ]
}

action "Test Deployment" {
  uses = "actions/bin/filter@master"
  args = "environment test"
}

action "Production Deployment" {
  uses = "actions/bin/filter@master"
  args = "environment production"
}

action "Staging Deployment" {
  uses = "actions/bin/filter@master"
  args = "environment staging"
}

action "Deploy to Zeit Test" {
  uses = "actions/zeit-now@master"
  needs = ["Test Deployment"]
  runs = "now --public -n mysampleexpressapp-test"
  secrets = ["ZEIT_TOKEN"]
}

action "Deploy to Zeit Production" {
  uses = "actions/zeit-now@master"
  needs = ["Production Deployment"]
  runs = "now --public -n mysampleexpressapp-production"
  secrets = ["ZEIT_TOKEN"]
}

action "Deploy to Zeit Staging" {
  uses = "actions/zeit-now@master"
  needs = ["Staging Deployment"]
  runs = "now --public -n mysampleexpressapp-staging"
  secrets = ["ZEIT_TOKEN"]
}


