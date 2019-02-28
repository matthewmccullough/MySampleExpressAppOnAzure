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
  resolves = ["Update Deploy Status for Test"]
}

action "Env is Test" {
  uses = "actions/bin/filter@master"
  args = "environment test"
  needs = ["Debug"]
}

action "Deploy to Zeit Test" {
  uses = "actions/zeit-now@master"
  secrets = ["ZEIT_TOKEN"]
  args = "--public -n mysampleexpressapp-test -m test=true -m ref=$GITHUB_REF > $HOME/zeit-test.out"
  needs = ["Env is Test"]
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
    "Clean up Zeit Production",
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

workflow "Cleanup envs" {
  on = "pull_request"
  resolves = ["debug zeit output"]
}

action "Debug" {
  uses = "hmarr/debug-action@master"
}

action "Filters for closed PRs" {
  uses = "actions/bin/filter@master"
  args = "action closed"
}

action "List instances" {
  uses = "actions/zeit-now@master"
  needs = ["Filters for closed PRs"]
  args = "ls -m ref=$GITHUB_REF > $HOME/zeit_instances.out"
  secrets = ["ZEIT_TOKEN"]
}

action "debug zeit output" {
  uses = "helaili/debug-action@9c691e6c7ca1c8dd6fce3e7fbb7edbccf93bcc32"
  needs = ["List instances"]
  args = "$HOME/zeit_instances.out"
}
