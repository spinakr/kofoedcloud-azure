param location string = resourceGroup().location
param appInsightsName string

resource logAnalyticsWorkspaceResource 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${appInsightsName}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: '0.023'
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource appInsightsResource 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceResource.id
  }
}

output appInnsightsName string = appInsightsResource.name
