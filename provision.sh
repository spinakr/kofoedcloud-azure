date=$(date '+%Y-%m-%d_%H-%M')
echo "Creating deployment of resources $date"

## Create EntraId App registration
appId=$(az ad app create --display-name 'drueriket' \
    --sign-in-audience 'AzureAdMyOrg' \
    --web-redirect-uris 'https://localhost:7247/signin-oidc' 'https://drueriket.azurewebsites.net/signin-oidc' \
    --only-show-errors \
    --query appId --output tsv)

##Add client secret with expiration. The default is one year.
clientsecret=$(az ad app credential reset \
    --id $appId \
    --display-name drueriket-web-secret \
    --years 1 \
    --only-show-errors \
    --query password \
    --output tsv)

az deployment sub create \
    --name cli-deployment-$date \
    --template-file infra/main.bicep  \
    --parameters entraAppId=$appId entraClientSecret=$clientsecret \
    --location 'norwayeast' \

# #set azure appconfig values that cannot be set in bicep
az appconfig kv set --name 'kofoedcloud-appconfig' --key 'Logging:LogLevel:Default' --value 'Error' --yes --only-show-errors
az appconfig kv set --name 'kofoedcloud-appconfig' --key 'Logging:LogLevel:Microsoft' --value 'Error' --yes --only-show-errors

