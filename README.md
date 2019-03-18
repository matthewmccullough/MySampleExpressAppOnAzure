[![Build Status](https://dev.azure.com/matthewatgithub/MySampleExpressAppOnAzure/_apis/build/status/matthewmccullough.MySampleExpressAppOnAzure?branchName=master)](https://dev.azure.com/matthewatgithub/MySampleExpressAppOnAzure/_build/latest?definitionId=2&branchName=master)

# A sample app
This application demonstrates the power of GitHub and Azure DevOps, running in harmony.

# Technologies used
- GitHub repos
- GitHub Pull Requests
- GitHub web UI for editing files
- Visual Studio Code
- Azure DevOps Boards
- Azure DevOps Pipelines
- Azure Web Apps

# Resources

- [git-pr-release-action](https://github.com/bakunyo/git-pr-release-action)
- [git-pr-release marketplace](https://github.com/marketplace/actions/git-pr-release)

# How to generate a release

1. Make your changes in a branch and open a PR with `master` as the base branch
2. stage those changes by opening a PR between your working branch and `staging`
3. when you’re ready to add that commit to a release, merge the PR into `staging`.
4. the action will automatically run and either open a release PR with all the PRs and commits that have been merged in `staging` and that area currently open against `master


# Thanks to
- Pavan Ravipati
- Bas Peters
- Alain Helaili
- Pierluigi Cau

