targetScope = 'subscription'


// @description('Id of the user or app to assign application roles')
// param principalId string = ''

// @secure()
// @description('SQL Server administrator password')
// param sqlAdminPassword string

// @secure()
// @description('Application user password')
// param appUserPassword string

@secure()
@description('EntraId Client Secret')
param entraClientSecret string

@description('EntraId App Id')
param entraAppId string

var location = 'norwayeast'

resource rgShared 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-kofoedcloud-shared'
  location: location
}

resource rgDrueriket 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-drueriket'
  location: location
}

module roleAssignments 'shared/roleAssignments.bicep' = {
  name: 'roleAssignmentsResources'
}

module configuration 'shared/configuration.bicep' = {
  scope: rgShared
  name: 'configurationResources'
  params: {
    appConfigName: 'kofoedcloud-appconfig'
    vaultName: 'kofoedcloud-keyvault'
    entraAppId: entraAppId
    entraClientSecret: entraClientSecret
  }
}

module appserviceplan 'shared/appserviceplan.bicep' = {
  scope: rgShared
  name: 'appserviceplanresources'
  params: {
    name: 'kofoedcloud-appserviceplan'
    location: location
  }
}

module loganalytics 'shared/monitoring.bicep' = {
  scope: rgShared
  name: 'logResources'
  params: {
    location: location
    appInsightsName: 'kofoedcloud-appinsights'
  }
}

module drueriket 'drueriket/main.bicep' = {
  scope: rgDrueriket
  name: 'drueriketResources'
  params: {
    sharedResourceGroupName: rgShared.name
    location: location
    appConfigName: configuration.outputs.appConfigName
    appServicePlanName: appserviceplan.outputs.name
    appInnsightsName: loganalytics.outputs.appInnsightsName
    webAppName: 'drueriket'
    vaultName: configuration.outputs.vaultName  
  }
}
