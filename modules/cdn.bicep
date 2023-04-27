@description('Hostname of the origin server')
param originHostName string

@description('CDN profile name')
param profileName string = 'cdn-${uniqueString(resourceGroup().id)}'

@description('CDN endpoint name')
param endpointName string = 'endpint-${uniqueString(resourceGroup().id)}'

@description('Does CDN requires HTTPS connections?')
param httpsOnly bool

var originName = 'my-origin'

resource cdnProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: profileName
  location: 'global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2022-11-01-preview' = {
  name: endpointName
  parent: cdnProfile
  location: 'global'
  properties:{
    originHostHeader: originHostName
    isHttpAllowed: !httpsOnly
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: originName
        properties: {
          hostName: originHostName
        } 
      }
    ]
  }
}

@description('Hostnmae of the CDN enpoint')
output endpointHostName string = endpoint.properties.hostName
