@description('The Azure regions to be used by the resources!')
param locations array = [ 'westeurope', 'eastasia', 'southeastasia' ]

@secure()
@description('The SQL Server login username.')
param sqlServerAdministratorLogin string

@secure()
@description('The SQL Server login password.')
param sqlServerAdministratorPassword string

@description('The CDIR for all virtual networks.')
param virtualNetworkCidr string = '11.10.0.0/16'

@description('Name and IP address range for each subnet.')
param subnets array = [
  {
    name: 'fe'
    ipAddressRange: '11.10.5.0/24'
  }
  {
    name: 'be'
    ipAddressRange: '11.10.7.0/24'
  }
]

var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }
}]

module databases 'modules/databases.bicep' = [for location in locations: {
  name: 'database-${location}'
  params: {
    location: location
    sqlAdministratorLogin: sqlServerAdministratorLogin
    sqlAdministratorPassword: sqlServerAdministratorPassword
  }
}]

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2022-09-01' = [for location in locations: {
  name: 'teddybear-${location}'
  location: location
  properties:{
    addressSpace: {
      addressPrefixes: [virtualNetworkCidr]
    }
    subnets: subnetProperties
  }
}]

output serverInfo array = [ for i in range(0,length(locations)): {
  name:     databases[i].outputs.serverName
  location: databases[i].outputs.location
  fqdn:     databases[i].outputs.serverFQDN
}]
