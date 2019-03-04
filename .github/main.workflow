workflow "Continuous Integration" {
  on = "push"
  resolves = ["Test", "Build Docker Image"]
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
  resolves = ["Build Docker Image"]
}

action "Env is Test" {
  uses = "actions/bin/filter@master"
  args = "environment test"
}

action "Build Docker Image" {
  uses = "actions/docker/cli@master"
  needs = ["Env is Test"]
  args = "build -t octodemo/mysampleexpressappazure:$GITHUB_SHA -t octodemo/mysampleexpressappazure-$GITHUB_REF ."
}
