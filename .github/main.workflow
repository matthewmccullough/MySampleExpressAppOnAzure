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
  resolves = ["Deploy to Zeit"]
}

action "Deploy to Zeit" {
  uses = "actions/zeit-now@master"
}
