Need to create a resource group, registry and service plan

>az ad sp create-for-rbac
{
  "appId": "xxxx",
  "displayName": "xx",
  "name": "http://azure-cli-yyyy",
  "password": "xxxx",
  "tenant": "xxxx-xxxx-xxxx-xxxx-xxxx"
}


az login -p $AZURE_SERVICE_PASSWORD -t $AZURE_SERVICE_TENANT  --service-principal --username $AZURE_SERVICE_APP_ID

docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD  $DOCKER_REGISTRY_URL

az webapp create --resource-group $RESOURCE_GROUP --plan $APP_SERVICE_PLAN --name $WEBAPP_NAME --deployment-container-image-name $CONTAINER_IMAGE_NAME --output json > azure_webapp_creation.json

az webapp config container show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP

az webapp config container set --docker-custom-image-name $CONTAINER_IMAGE_NAME --docker-registry-server-url $DOCKER_REGISTRY_URL --docker-registry-server-password $DOCKER_PASSWORD --docker-registry-server-user $DOCKER_USERNAME --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --subscription $AZURE_SUBSCRIPTION_ID


az webapp update -g $RESOURCE_GROUP -n $WEBAPP_NAME --set tags.branch=xxx


GITHUB_SHA=ef0a7f90b63cea580251df4ec71bd9f8b4f2645c
BRANCH=$(jq -r '.deployment.ref' $GITHUB_EVENT_PATH) && az webapp update -g $RESOURCE_GROUP -n $WEBAPP_NAME-${GITHUB_SHA:0:7} --set tags.branch=$BRANCH

az webapp list --resource-group $RESOURCE_GROUP --query "[?tags.branch=='clean']"


az webapp delete --ids /subscriptions/282bf220-8943-485c-abaf-187252d34b78/resourceGroups/github-octodemo/providers/Microsoft.Web/serverfarms/github-octodemo-app-service-plan
