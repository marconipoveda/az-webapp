@description('The name of the environment.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The unique name of the solution.')
@minLength(5)
@maxLength(30)
param solutionName string = 'toyshr${uniqueString(resourceGroup().id)}'

@description('The number of instances to create for the App Service Plan.')
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

@description('The name and tier of the App Service Plan SKU.')
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
}

@description('The location of the resources. It uses the resource group location by default.')
param location string = 'eastasia'

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
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
