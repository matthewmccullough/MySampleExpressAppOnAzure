workflow "Create Release" {
  on = "push"
  resolves = ["git-pr-release"]
}

action "Master branch?" {
  uses = "actions/bin/filter@d820d56839906464fb7a57d1b4e1741cf5183efa"
  args = "branch master"
}

action "git-pr-release" {
  uses = "bakunyo/git-pr-release-action@master"
  needs = ["Master branch?"]
  secrets = ["GITHUB_TOKEN"]
}
