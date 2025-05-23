metadata name = 'Synapse Workspaces Big Data Pools'
metadata description = 'This module deploys Synapse Workspaces Big Data Pools.'

@description('Conditional. The name of the parent Synapse Workspace. Required if the template is used in a standalone deployment.')
param workspaceName string

@description('Required. The name of the Big Data Pool.')
param name string

@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Auto-pausing properties.')
param autoPause autoPauseType = {
  delayInMinutes: 15
  enabled: true
}

@description('Optional. Auto-scaling properties.')
param autoScale autoScaleType = {
  enabled: true
  maxNodeCount: '5'
  minNodeCount: '3'
}

@description('Optional. The cache size.')
@minValue(0)
@maxValue(100)
param cacheSize int = 50

// @description('Optional. List of custom libraries/packages associated with the spark pool.')
// param customLibraries libraryInfoType[] = []

// @description('The default folder where Spark logs will be written.')
// param defaultSparkLogFolder string?

// @description('Optional. Dynamic Executor Allocation.')
// param dynamicExecutorAllocation dynamicExecutorAllocationType = {
//   enabled: false
//   maxExecutors: '2'
//   minExecutors: '1'
// }

// @description('Whether autotune is required or not.')
// param isAutotuneEnabled bool = false

// @description('Whether compute isolation is required or not.')
// param isComputeIsolationEnabled bool = false

// @description('Library version requirements.')
// param libraryRequirements libraryRequirementsType?

@description('Optional. The number of nodes in the Big Data pool.')
param nodeCount int = 3

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

@allowed([
  'HardwareAcceleratedFPGA'
  'HardwareAcceleratedGPU'
  'MemoryOptimized'
  'None'
])
@description('Required. The kind of nodes that the Big Data pool provides.')
param nodeSizeFamily string

@description('Optional. Whether session level packages enabled.')
param sessionLevelPackagesEnabled bool = true

// @description('Spark configuration file to specify additional properties.')
// param sparkConfigProperties sparkConfigPropertiesType?

// @description('The Spark events folder.')
// param sparkEventsFolder string?

@description('Required. The Apache Spark version.')
param sparkVersion string

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
          enabled: autoScale.?enabled
          // To handle fractional values, we need to convert from string :(
          maxNodeCount: json(autoScale.?maxNodeCount)
          minNodeCount: json(autoScale.?minNodeCount)
        }
      : null
    nodeCount: empty(autoScale) ? nodeCount : null
    //dynamicExecutorAllocation: !empty(dynamicExecutorAllocation)
      ? {
          enabled: dynamicExecutorAllocation.?enabled
          // To handle fractional values, we need to convert from string :(
          maxExecutors: json(dynamicExecutorAllocation.?maxExecutors)
          minExecutors: json(dynamicExecutorAllocation.?minExecutors)
        }
      : null
    autoPause: !empty(autoPause)
      ? {
          enabled: autoPause.?enabled
          delayInMinutes: autoPause.?delayInMinutes
        }
      : null
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
@description('The synapse workspace Big Data Pools Auto-pausing properties.')
type autoPauseType = {
  @description('Required. Synapse workspace Big Data Pools Auto-pausing delay in minutes.')
  delayInMinutes: int

  @description('Required. Synapse workspace Big Data Pools Auto-pausing enabled.')
  enabled: bool
}

@export()
@description('The synapse workspace Big Data Pools Auto-scaling properties.')
type autoScaleType = {
  @description('Required. Synapse workspace Big Data Pools Auto-scaling enabled.')
  enabled: bool

  @description('Required. Synapse workspace Big Data Pools Auto-scaling maximum node count.')
  maxNodeCount: string

  @description('Required. Synapse workspace Big Data Pools Auto-scaling minimum node count.')
  minNodeCount: string
}

@export()
@description('The synapse workspace Big Data Pools Dynamic Executor Allocation properties.')
type dynamicExecutorAllocationType = {
  @description('Required. Synapse workspace Big Data Pools Dynamic Executor Allocation enabled.')
  enabled: bool

  @description('Required. Synapse workspace Big Data Pools Dynamic Executor Allocation maximum executors.')
  maxExecutors: string

  @description('Required. Synapse workspace Big Data Pools Dynamic Executor Allocation minimum executors.')
  minExecutors: string
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
