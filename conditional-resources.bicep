@description('Azure region to deploy the resources to')
param location string

@secure()
@description('The username for the SQL Server Administrator')
param sqlServerAdministratorLogin string

@secure()
@description('The password for the SQL Server Administrator')
param sqlServerAdministratorPassword string

@description('The name and tier of the SQL database SKU')
param sqlDatabaseSku object = {
  name: 'Standard'
  tier: 'Standard'
}

@description('The name of the environment. This must be Dev or Prod')
@allowed(['Dev', 'Prod'])
param environmentName string = 'Dev'

@description('The name of the audit storage account SKU')
param auditStorageAccountSkuName object = {
  name: 'Standard_LRS'
}

var sqlServerName = 'teddy${location}${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'TeddyBear'
var auditEnabled = environmentName == 'Prod'
var auditStorageAccountName = take('bearaudit${location}${uniqueString(resourceGroup().id)}', 24)

resource sqlServer 'Microsoft.Sql/servers@2022-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: sqlDatabaseSku
}

resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' =  if (auditEnabled){
  name: auditStorageAccountName
  location: location
  sku: {
    name: auditStorageAccountSkuName.name
  }
  kind: 'StorageV2'
}

resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2022-08-01-preview' = if (auditEnabled) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    storageEndpoint: environmentName == 'Prod' ? auditStorageAccount.properties.primaryEndpoints.blob : ''
    storageAccountAccessKey: environmentName == 'Prod' ? auditStorageAccount.listKeys().keys[0].value : ''
  }
}
