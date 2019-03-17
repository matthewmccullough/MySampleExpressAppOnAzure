workflow "Create PR to master" {
  resolves = ["git-pr-release"]
  on = "push"
}

action "Filter branch" {
  uses = "actions/bin/filter@24a566c2524e05ebedadef0a285f72dc9b631411"
  args = "branch staging"
}

action "git-pr-release" {
  uses = "bakunyo/git-pr-release-action@master"
  needs = ["Filter branch"]
  secrets = ["GITHUB_TOKEN"]
}
