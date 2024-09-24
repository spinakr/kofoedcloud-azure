param location string = resourceGroup().location
param appInnsightsName string
param webAppName string
param appServicePlanName string
param appConfigName string
param vaultName string
param sharedResourceGroupName string

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: resourceGroup(sharedResourceGroupName)
  name: appInnsightsName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  scope: resourceGroup(sharedResourceGroupName)
  name: appServicePlanName
}

resource configStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  scope: resourceGroup(sharedResourceGroupName)
  name: appConfigName
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: toLower(webAppName)
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}


resource siteConfig 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: appService
  name: 'web'
  properties: {
    netFrameworkVersion: 'v8.0'
    numberOfWorkers: 1
    webSocketsEnabled: true
    alwaysOn: false
    publicNetworkAccess: 'Enabled'
    minTlsVersion: '1.2'
    windowsFxVersion: ''
    scmMinTlsVersion: '1.2'
    metadata: [
      {
        name: 'CURRENT_STACK'
        value: 'dotnet'
      }
    ]
  }
}

resource appServiceLogging 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: appService
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    DOTNET_ENVIRONMENT: 'Production'
    AppConfigConnectionString: configStore.listKeys().value[0].connectionString
  }
}


// Add key vault secret user role to web app
module kvRoleAssignment '../shared/role-assignments/keyvault-role-assigment.bicep' = {
  name: 'KvRoleAssignmentWebApp'
  scope: resourceGroup(sharedResourceGroupName)
  params: {
    keyVaultName: vaultName
    principalId: appService.identity.principalId
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'
  }
}

// Add App Configuration Data Reader role to web app
module appConfigRoleAssigmnet '../shared/role-assignments/app-config-store-role-assigment.bicep' = {
  name: 'appConfigRoleAssigment'
  scope: resourceGroup(sharedResourceGroupName)
  params: {
    configStoreName: appConfigName
    principalId: appService.identity.principalId
    roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071'
  }
}

