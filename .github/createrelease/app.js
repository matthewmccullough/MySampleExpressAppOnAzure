const Octokit = require('@octokit/rest')
const fs = require('fs');

cont githubToken = process.env.GITHUB_TOKEN

const octokit = new Octokit({
  auth: githubToken
})
 
const pushEvent = process.env.GITHUB_EVENT_PATH

const pushPayload = JSON.parse(fs.readFileSync(pushEvent, 'utf8'));

console.log(pushPayload.commits[][message])

// Compare: https://developer.github.com/v3/repos/#list-organization-repositories
octokit.repos.listForOrg({
  org: 'octokit',
  type: 'public'
}).then(({ data, status, headers }) => {

})

const result = await octokit.issues.create({"matthewmccullough", "MySampleExpressAppOnAzure", "testing the action", "did it work", "pravipati"})