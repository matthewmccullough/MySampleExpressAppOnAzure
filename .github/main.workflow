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
  resolves = ["Remove old deployment"]
}

action "Deploy to Zeit" {
  uses = "actions/zeit-now@master"
  runs = "now --public -n mysampleexpressapp"
  secrets = ["ZEIT_TOKEN"]
}

action "Remove old deployment" {
  uses = "actions/zeit-now@666edee2f3632660e9829cb6801ee5b7d47b303d"
  needs = ["Deploy to Zeit"]
  secrets = ["ZEIT_TOKEN"]
  runs = "now rm mysampleexpressapp --safe --yes"
}
