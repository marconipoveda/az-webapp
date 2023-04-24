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
param appServicePlanSku object

@description('The location of the resources. It uses the resource group location by default.')
param location string = 'eastasia'

@secure()
@description('Administrator login username for the SQL server')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL database')
param sqlServerAdministratorPassword string

@description('The name and tier of the SQL database SKU')
param sqlDatabaseSku object

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'
var sqlServerName = '${environmentName}-${solutionName}-sql'
var sqlDatabaseName = 'Employees'

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

resource sqlServer 'Microsoft.Sql/servers@2022-08-01-preview' = {
  name: sqlServerName
  location: location
  properties:{
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword:sqlServerAdministratorPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  name: sqlDatabaseName
  location: location
  parent: sqlServer
  sku:{
    name: sqlDatabaseSku.name
    tier: sqlDatabaseSku.tier
  }
}
