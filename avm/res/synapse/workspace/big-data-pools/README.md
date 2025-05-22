# Synapse Workspaces Big Data Pools `[Microsoft.Synapse/workspaces/bigDataPools]`

This module deploys Synapse Workspaces Big Data Pools.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Synapse/workspaces/bigDataPools` | [2021-06-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Synapse/2021-06-01/workspaces/bigDataPools) |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the Big Data Pool. |
| [`nodeSize`](#parameter-nodesize) | string | The level of compute power that each node in the Big Data pool has. |
| [`nodeSizeFamily`](#parameter-nodesizefamily) | string | The kind of nodes that the Big Data pool provides. |
| [`sparkVersion`](#parameter-sparkversion) | string | The Apache Spark version. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`workspaceName`](#parameter-workspacename) | string | The name of the parent Synapse Workspace. Required if the template is used in a standalone deployment. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`autoPause`](#parameter-autopause) | object | Auto-pausing properties. |
| [`autoScale`](#parameter-autoscale) | object | Auto-scaling properties. |
| [`cacheSize`](#parameter-cachesize) | int | The cache size. |
| [`dynamicExecutorAllocation`](#parameter-dynamicexecutorallocation) | object | Dynamic Executor Allocation. |
| [`location`](#parameter-location) | string | The geo-location where the resource lives. |
| [`nodeCount`](#parameter-nodecount) | int | The number of nodes in the Big Data pool. |
| [`sessionLevelPackagesEnabled`](#parameter-sessionlevelpackagesenabled) | bool | Whether session level packages enabled. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |

### Parameter: `name`

The name of the Big Data Pool.

- Required: Yes
- Type: string

### Parameter: `nodeSize`

The level of compute power that each node in the Big Data pool has.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Large'
    'Medium'
    'None'
    'Small'
    'XLarge'
    'XXLarge'
    'XXXLarge'
  ]
  ```

### Parameter: `nodeSizeFamily`

The kind of nodes that the Big Data pool provides.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'HardwareAcceleratedFPGA'
    'HardwareAcceleratedGPU'
    'MemoryOptimized'
    'None'
  ]
  ```

### Parameter: `sparkVersion`

The Apache Spark version.

- Required: Yes
- Type: string

### Parameter: `workspaceName`

The name of the parent Synapse Workspace. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

### Parameter: `autoPause`

Auto-pausing properties.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      delayInMinutes: 15
      enabled: true
  }
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`delayInMinutes`](#parameter-autopausedelayinminutes) | int | Synapse workspace Big Data Pools Auto-pausing delay in minutes. |
| [`enabled`](#parameter-autopauseenabled) | bool | Synapse workspace Big Data Pools Auto-pausing enabled. |

### Parameter: `autoPause.delayInMinutes`

Synapse workspace Big Data Pools Auto-pausing delay in minutes.

- Required: Yes
- Type: int

### Parameter: `autoPause.enabled`

Synapse workspace Big Data Pools Auto-pausing enabled.

- Required: Yes
- Type: bool

### Parameter: `autoScale`

Auto-scaling properties.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      enabled: true
      maxNodeCount: '5'
      minNodeCount: '3'
  }
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-autoscaleenabled) | bool | Synapse workspace Big Data Pools Auto-scaling enabled. |
| [`maxNodeCount`](#parameter-autoscalemaxnodecount) | string | Synapse workspace Big Data Pools Auto-scaling maximum node count. |
| [`minNodeCount`](#parameter-autoscaleminnodecount) | string | Synapse workspace Big Data Pools Auto-scaling minimum node count. |

### Parameter: `autoScale.enabled`

Synapse workspace Big Data Pools Auto-scaling enabled.

- Required: Yes
- Type: bool

### Parameter: `autoScale.maxNodeCount`

Synapse workspace Big Data Pools Auto-scaling maximum node count.

- Required: Yes
- Type: string

### Parameter: `autoScale.minNodeCount`

Synapse workspace Big Data Pools Auto-scaling minimum node count.

- Required: Yes
- Type: string

### Parameter: `cacheSize`

The cache size.

- Required: No
- Type: int
- Default: `50`
- MinValue: 0
- MaxValue: 100

### Parameter: `dynamicExecutorAllocation`

Dynamic Executor Allocation.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      enabled: false
      maxExecutors: '2'
      minExecutors: '1'
  }
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-dynamicexecutorallocationenabled) | bool | Synapse workspace Big Data Pools Dynamic Executor Allocation enabled. |
| [`maxExecutors`](#parameter-dynamicexecutorallocationmaxexecutors) | string | Synapse workspace Big Data Pools Dynamic Executor Allocation maximum executors. |
| [`minExecutors`](#parameter-dynamicexecutorallocationminexecutors) | string | Synapse workspace Big Data Pools Dynamic Executor Allocation minimum executors. |

### Parameter: `dynamicExecutorAllocation.enabled`

Synapse workspace Big Data Pools Dynamic Executor Allocation enabled.

- Required: Yes
- Type: bool

### Parameter: `dynamicExecutorAllocation.maxExecutors`

Synapse workspace Big Data Pools Dynamic Executor Allocation maximum executors.

- Required: Yes
- Type: string

### Parameter: `dynamicExecutorAllocation.minExecutors`

Synapse workspace Big Data Pools Dynamic Executor Allocation minimum executors.

- Required: Yes
- Type: string

### Parameter: `location`

The geo-location where the resource lives.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `nodeCount`

The number of nodes in the Big Data pool.

- Required: No
- Type: int
- Default: `3`

### Parameter: `sessionLevelPackagesEnabled`

Whether session level packages enabled.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the deployed Big Data Pool. |
| `resourceGroupName` | string | The resource group of the deployed Big Data Pool. |
| `resourceId` | string | The resource ID of the deployed Big Data Pool. |
