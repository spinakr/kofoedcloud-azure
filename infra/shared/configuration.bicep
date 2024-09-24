param location string = resourceGroup().location
param appConfigName string
param vaultName string
param entraAppId string
@secure()
param entraClientSecret string


resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  properties: {
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource kvSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: vault
  name: 'entraid-client-secret'
  properties: {
    contentType: 'text/plain'
    value: entraClientSecret
  }
}

param keyValueNames array = [
  'EntraId:Instance'
  'EntraId:Domain'
  'EntraId:TenantId'
  'EntraId:ClientId'
  'EntraId:CallbackPath'
  'DownsteamApi:BaseUrl'
  'DownsteamApi:Scopes:0'
  'AllowedHosts'
]

param keyValueValues array = [
  'https://login.microsoftonline.com/'
  'kofoed.cloud'
  '85467a21-50ed-4b1e-8119-95aa483c119f'
  entraAppId
  '/signin-oidc'
  'https://graph.microsoft.com/v1.0'
  'User.Read'
  '*'
]

resource configStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appConfigName
  location: location
  sku: {
    name: 'free'
  }
}

resource configSecret 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  // Store secrets in Key Vault with a reference to them in App Configuration e.g., client secrets, connection strings, etc.
  parent: configStore
  name: 'EntraId:ClientSecret'
  properties: {
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
    value: '{"uri":"${kvSecret.properties.secretUri}"}'
  }
}

resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in keyValueNames: {
  parent: configStore
  name: item
  properties: {
    value: keyValueValues[i]
  }
}]

output appConfigName string = configStore.name
output vaultName string = vault.name
