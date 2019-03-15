workflow "Create Release" {
  on = "push"
  resolves = ["./.github/updatechangelog"]
}

action "Master branch?" {
  uses = "actions/bin/filter@d820d56839906464fb7a57d1b4e1741cf5183efa"
  args = "branch master"
}

action "./.github/updatechangelog" {
  uses = "./.github/updatechangelog"
  needs = ["Master branch?"]
  secrets = [
    "GITHUB_TOKEN",
  ]
}
