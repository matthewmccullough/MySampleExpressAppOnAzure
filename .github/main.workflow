workflow "Create Release" {
  on = "push"
  resolves = ["./.github/updatechangelog"]
}

action "Master branch?" {
  uses = "actions/bin/filter@d820d56839906464fb7a57d1b4e1741cf5183efa"
  args = "branch master"
}

action "./.github/createrelease" {
  uses = "./.github/createrelease"
  needs = ["Master branch?"]
  secrets = [
    "GITHUB_TOKEN",
  ]
}
