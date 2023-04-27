@description('The Azure region into which the resources will be deployed')
param location string

@description('Name of the AppService app.')
param appServiceAppName string

@description('Name of the AppService plan.')
param appServicePlanName string

@description('The name of the App Serviuce plan SKU')
param appServicePlanSkuName string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

@description('The default hostname of the app service app')
output appServiceAppHostname string = appServiceApp.properties.defaultHostName
