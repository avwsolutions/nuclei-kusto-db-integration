param appName string
param environment string
param location string
param servicepPrincipalObjectId string

var logIngestion = {
  transformationKustoQuery: 'source | extend TimeGenerated = timestamp | project-rename [\'curl_command\'] = [\'curl-command\'], [\'extracted_results\'] = [\'extracted-results\'], [\'extractor_name\'] = [\'extractor-name\'], [\'matched_at\'] = [\'matched-at\'], [\'matcher_status\'] = [\'matcher-status\'], [\'matcher_name\'] = [\'matcher-name\'], [\'template_id\'] = [\'template-id\'], [\'template_path\'] = [\'template-path\'], nuclei_type = type'
  incomingTableSchema: [
    {
      name: 'curl-command'
      type: 'string'
    }
    {
      name: 'extractor-name'
      type: 'string'
    }
    {
      name: 'extracted-results'
      type: 'dynamic'
    }
    {
      name: 'host'
      type: 'string'
    }
    {
      name: 'info'
      type: 'dynamic'
    }
    {
      name: 'ip'
      type: 'string'
    }
    {
      name: 'matched-at'
      type: 'string'
    }
    {
      name: 'matcher-name'
      type: 'string'
    }
    {
      name: 'matcher-status'
      type: 'string'
    }
    {
      name: 'type'
      type: 'string'
    }
    {
      name: 'port'
      type: 'string'
    }
    {
      name: 'request'
      type: 'string'
    }
    {
      name: 'response'
      type: 'string'
    }
    {
      name: 'scheme'
      type: 'string'
    }
    {
      name: 'template-id'
      type: 'string'
    }
    {
      name: 'template-path'
      type: 'string'
    }
    {
      name: 'timestamp'
      type: 'datetime'
    }
    {
      name: 'url'
      type: 'string'
    }
  ]
  storedTableSchema: [
    {
      name: 'curl_command'
      type: 'string'
    }
    {
      name: 'extractor_name'
      type: 'string'
    }
    {
      name: 'extracted_results'
      type: 'dynamic'
    }
    {
      name: 'host'
      type: 'string'
    }
    {
      name: 'info'
      type: 'dynamic'
    }
    {
      name: 'ip'
      type: 'string'
    }
    {
      name: 'matched_at'
      type: 'string'
    }
    {
      name: 'matcher_name'
      type: 'string'
    }
    {
      name: 'matcher_status'
      type: 'string'
    }
    {
      name: 'nuclei_type'
      type: 'string'
    }
    {
      name: 'port'
      type: 'string'
    }
    {
      name: 'request'
      type: 'string'
    }
    {
      name: 'response'
      type: 'string'
    }
    {
      name: 'scheme'
      type: 'string'
    }
    {
      name: 'template_id'
      type: 'string'
    }
    {
      name: 'template_path'
      type: 'string'
    }
    {
      name: 'TimeGenerated'
      type: 'datetime'
    }
    {
      name: 'timestamp'
      type: 'datetime'
    }
    {
      name: 'url'
      type: 'string'
    }
  ]
}

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
    transformationKustoQuery: logIngestion.transformationKustoQuery
    incomingTableSchema: logIngestion.incomingTableSchema
    storedTableSchema: logIngestion.storedTableSchema
    location: location
    logAnalyticsName: law.outputs.logAnalyticsName
    logIngestionName: appName
    servicepPrincipalObjectId: servicepPrincipalObjectId
  }
}
