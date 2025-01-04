param appName string = 'nuclei'
param environment string = 'dev'
param location string = 'westeurope'

param servicepPrincipalObjectId string

param buildId string = utcNow()

var namingPrefix = '${appName}-${environment}'
var naming = {
  logAnalytics: '${namingPrefix}-law'
  dataCollectionRule: '${namingPrefix}-dcr'
  dataCollectionEndpoint: '${namingPrefix}-dce'
}

module law 'law.bicep' = {
  name: 'law-${buildId}'
  params: {
    location: location
    logAnalyticsName: naming.logAnalytics
  }
}

module datacollection 'datacollection.bicep' = {
  name: 'datacollection-${buildId}'
  params: {
    dataCollectionEndpointName: naming.dataCollectionEndpoint
    dataCollectionRuleName: naming.dataCollectionRule
    location: location
    logAnalyticsName: law.outputs.logAnalyticsName
    logIngestionName: appName
    servicepPrincipalObjectId: servicepPrincipalObjectId
  }
}
