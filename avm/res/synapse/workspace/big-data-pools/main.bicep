metadata name = 'Synapse Workspaces Big Data Pools'
metadata description = 'This module deploys Synapse Workspaces Big Data Pools.'

// ================ //
// Parameters       //
// ================ //

@description('Conditional. The name of the parent Synapse Workspace. Required if the template is used in a standalone deployment.')
param workspaceName string

@description('Required. The name of the Big Data Pool.')
param name string

@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. The kind of nodes that the Big Data pool provides.')
@allowed([
  'HardwareAcceleratedFPGA'
  'HardwareAcceleratedGPU'
  'MemoryOptimized'
  'None'
])
param nodeSizeFamily string = 'MemoryOptimized'

@allowed([
  'Large'
  'Medium'
  'None'
  'Small'
  'XLarge'
  'XXLarge'
  'XXXLarge'
])
@description('Required. The level of compute power that each node in the Big Data pool has.')
param nodeSize string

@description('Optional. Auto-scaling properties.')
param autoScale autoScaleType?

@description('Optional. The number of nodes in the Big Data pool if Auto-scaling is disabled.')
@minValue(3)
@maxValue(200)
param nodeCount int = 3

@description('Optional. Dynamic Executor Allocation.')
param dynamicExecutorAllocation dynamicExecutorAllocationType?

@description('Optional. Synapse workspace Big Data Pools Auto-pausing delay in minutes (5-10080). Disabled if value not provided.')
@minValue(-1)
@maxValue(10080) // 7 days in minutes
param autoPauseDelayInMinutes int = -1

@description('Required. The Apache Spark version.')
param sparkVersion string

@description('Optional. The cache size.')
@minValue(0)
@maxValue(100)
param cacheSize int = 50

// @description('Optional. List of custom libraries/packages associated with the spark pool.')
// param customLibraries libraryInfoType[] = []

// @description('The default folder where Spark logs will be written.')
// param defaultSparkLogFolder string?

// @description('Whether autotune is required or not.')
// param isAutotuneEnabled bool = false

// @description('Whether compute isolation is required or not.')
// param isComputeIsolationEnabled bool = false

// @description('Library version requirements.')
// param libraryRequirements libraryRequirementsType?

@description('Optional. Whether session level packages enabled.')
param sessionLevelPackagesEnabled bool = false

// @description('Spark configuration file to specify additional properties.')
// param sparkConfigProperties sparkConfigPropertiesType?

// @description('The Spark events folder.')
// param sparkEventsFolder string?

@description('Optional. Tags of the resource.')
param tags object?

resource workspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: workspaceName
}

resource bigDataPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  name: name
  parent: workspace
  location: location
  tags: tags
  properties: {
    nodeSizeFamily: nodeSizeFamily
    nodeSize: nodeSize
    autoScale: !empty(autoScale)
      ? {
          enabled: true
          minNodeCount: autoScale.minNodeCount
          maxNodeCount: autoScale.maxNodeCount
        }
      : {
          enabled: false
      }
    nodeCount: empty(autoScale) ? nodeCount : null
    dynamicExecutorAllocation: !empty(dynamicExecutorAllocation)
      ? {
          enabled: true
          // To handle fractional values, we need to convert from string :(
          maxExecutors: dynamicExecutorAllocation.maxExecutors
          minExecutors: dynamicExecutorAllocation.minExecutors
        }
      : {
          enabled: false
        }
    autoPause: autoPauseDelayInMinutes != -1
      ? {
          enabled: true
          delayInMinutes: autoPauseDelayInMinutes < 5 ? 5 : autoPauseDelayInMinutes // Minimum 5 minutes
        }
      : {
        enabled: false
      }
    sparkVersion: sparkVersion
    //sparkConfigProperties: sparkConfigProperties
    sessionLevelPackagesEnabled: sessionLevelPackagesEnabled
    cacheSize: cacheSize

    // customLibraries: customLibraries
    // defaultSparkLogFolder: defaultSparkLogFolder
    // isAutotuneEnabled: isAutotuneEnabled
    // isComputeIsolationEnabled: isComputeIsolationEnabled
    // libraryRequirements: libraryRequirements

    // sparkEventsFolder: sparkEventsFolder
  }
}

@description('The name of the deployed Big Data Pool.')
output name string = bigDataPool.name

@description('The resource ID of the deployed Big Data Pool.')
output resourceId string = bigDataPool.id

@description('The resource group of the deployed Big Data Pool.')
output resourceGroupName string = resourceGroup().name

// =============== //
//   Definitions   //
// =============== //

@export()
@description('The synapse workspace Big Data Pools Auto-scaling properties.')
type autoScaleType = {
  @description('Required. Synapse workspace Big Data Pools Auto-scaling maximum node count.')
  @minValue(3)
  @maxValue(200)
  maxNodeCount: int

  @description('Required. Synapse workspace Big Data Pools Auto-scaling minimum node count.')
  @minValue(3)
  @maxValue(200)
  minNodeCount: int
}

@export()
@description('The synapse workspace Big Data Pools Dynamic Executor Allocation properties.')
type dynamicExecutorAllocationType = {
  @description('Required. Synapse workspace Big Data Pools Dynamic Executor Allocation minimum executors.')
  @minValue(1)
  @maxValue(10)
  minExecutors: int

  @description('Required. Synapse workspace Big Data Pools Dynamic Executor Allocation maximum executors (maxNodeCount-1).')
  @minValue(1)
  @maxValue(10)
  maxExecutors: int
}

@export()
@description('The synapse workspace Big Data Pools Library version requirements.')
type libraryRequirementsType = {
  @description('Required. The library name.')
  content: string

  @description('Required. The library version.')
  filename: string
}

@export()
@description('The synapse workspace Big Data Pools Spark configuration file properties.')
type sparkConfigPropertiesType = {
  @description('Required. The configuration type.')
  configurationType: string

  @description('Required. The configuration content.')
  content: string

  @description('Required. The configuration filename.')
  filename: string
}

@export()
@description('The synapse workspace Big Data Pools Custom library/package info.')
type libraryInfoType = {
  @description('Required. The library name.')
  containerName: string

  @description('Required. The library version.')
  name: string

  @description('Required. The library path.')
  path: string

  @description('Required. The library type.')
  type: string
}
