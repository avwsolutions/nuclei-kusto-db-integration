param logIngestionName string
param location string
param logAnalyticsName string
param dataCollectionEndpointName string
param dataCollectionRuleName string
param servicepPrincipalObjectId string

param transformationKustoQuery string
param incomingTableSchema array
param storedTableSchema array

var customTableName = '${logIngestionName}_CL'
var dataCollectionStreamName = 'Custom-${customTable.name}'

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
      columns: storedTableSchema
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
        columns: incomingTableSchema
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
