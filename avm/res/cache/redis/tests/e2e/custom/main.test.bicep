targetScope = 'subscription'

metadata name = 'Using custom parameter set'
metadata description = 'This instance deploys the module with most of its features enabled.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-cache.redis-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'crcst'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

// ========== //
// Variables //
// ========== //

var diagnosticLogCategoriesToEnable array = [
  'allLogs'
]

var diagnosticsLogsSpecified = [
  for category in filter(diagnosticLogCategoriesToEnable, item => item != 'allLogs'): {
    category: category
    enabled: true
  }
]

var diagnosticsLogs = contains(diagnosticLogCategoriesToEnable, 'allLogs')
  ? [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  : diagnosticsLogsSpecified

var diagnosticMetricsToEnable array = [
  'AllMetrics'
]

var diagnosticsMetrics = [
  for metric in diagnosticMetricsToEnable: {
    category: metric
    enabled: true
  }
]

var redisConfiguration object = {}

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    location: resourceLocation
    virtualNetworkName: 'dep-${namePrefix}-vnet-${serviceShort}'
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../../../../utilities/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}diasa${serviceShort}01'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-${namePrefix}-evh-${serviceShort}'
    eventHubNamespaceName: 'dep-${namePrefix}-evhns-${serviceShort}'
    location: resourceLocation
  }
}

// ============== //
// Test Execution //
// ============== //

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      name: '${namePrefix}${serviceShort}001'
      capacity: 2
      diagnosticSettings: [
        {
          name: 'customSetting'
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
          metricCategories: diagnosticsMetrics
          logCategoriesAndGroups: diagnosticsLogs
        }
      ]
      enableNonSslPort: false
      location: resourceLocation
      managedIdentities: {
        systemAssigned: false
        userAssignedResourceIds: []
      }
      minimumTlsVersion: '1.2'
      shardCount: null
      skuName: 'Standard'
      publicNetworkAccess: null
      redisConfiguration: !empty(redisConfiguration) ? redisConfiguration : null
      redisVersion: '6'
      replicasPerMaster: null
      replicasPerPrimary: null
      subnetResourceId: null
      zoneRedundant: null
      availabilityZones: null
    }
  }
]
