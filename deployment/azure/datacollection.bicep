param logIngestionName string
param location string
param logAnalyticsName string
param dataCollectionEndpointName string
param dataCollectionRuleName string

param servicepPrincipalObjectId string

var customTableName = '${logIngestionName}_CL'
var dataCollectionStreamName = 'Custom-${customTable.name}'

var transformationKustoQuery = '''source | extend TimeGenerated = timestamp | project-rename ['curl_command'] = ['curl-command'], ['extracted_results'] = ['extracted-results'], ['extractor_name'] = ['extractor-name'], ['matched_at'] = ['matched-at'], ['matcher_status'] = ['matcher-status'], ['matcher_name'] = ['matcher-name'], ['template_id'] = ['template-id'], ['template_path'] = ['template-path'], nuclei_type = type'''
var tableSchema = [
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

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

resource customTable 'Microsoft.OperationalInsights/workspaces/tables@2023-09-01' = {
  name: customTableName
  parent: logAnalytics
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    totalRetentionInDays: 30
    schema: {
      name: customTableName
      columns: [
        {
          curl_command: 'string'
          extractor_name: 'string'
          extracted_results: 'dynamic'
          host: 'string'
          info: 'dynamic'
          ip: 'string'
          matched_at: 'string'
          matcher_name: 'string'
          matcher_status: 'boolean'
          nuclei_type: 'string'
          port: 'string'
          request: 'string'
          response: 'string'
          scheme: 'string'
          template_id: 'string'
          template_path: 'string'
          TimeGenerated: 'dateTime'
          timestamp: 'dateTime'
          url: 'string'
        }
      ]
    }
  }
}

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = {
  name: dataCollectionEndpointName
  location: location
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: dataCollectionRuleName
  location: location
  properties: {
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalytics.id
          name: guid(logAnalytics.id)
        }
      ]
    }
    dataCollectionEndpointId: dataCollectionEndpoint.id
    dataFlows: [
      {
        streams: [
          dataCollectionStreamName
        ]
        destinations: [
          guid(logAnalytics.id)
        ]
        outputStream: dataCollectionStreamName
        transformKql: transformationKustoQuery
      }
    ]
    streamDeclarations: {
      '${dataCollectionStreamName}': {
        columns: tableSchema
      }
    }
  }
}

resource dataCollectionRulePublisherGroup 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(servicepPrincipalObjectId, dataCollectionEndpoint.id)
  scope: dataCollectionRule
  properties: {
    principalId: servicepPrincipalObjectId
    // Monitoring Metrics Publisher
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')
  }
}

output dataCollectionRuleId string = dataCollectionRule.properties.immutableId
output dataCollectionLogIngestionEndpoint string = dataCollectionEndpoint.properties.logsIngestion.endpoint
output dataCollectionStreamName string = dataCollectionStreamName
