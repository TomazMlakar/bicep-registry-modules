targetScope = 'subscription'

metadata name = 'Using only defaults'
metadata description = 'This instance deploys the module with the minimum set of required parameters.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-cache.redis-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'crmin'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

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
    managedIdentityName: 'dep-${namePrefix}-msi-${serviceShort}'
    managedIdentityName2: 'dep-${namePrefix}-msi2-${serviceShort}'
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
      location: resourceLocation
      accessPolicies: [
        {
          name: 'Read Only Policy'
          permissions: '+@read'
        }
        {
          name: 'Write Only Policy'
          permissions: '+@write'
        }
        {
          name: 'Admin Policy'
          permissions: '+@all'
        }
        {
          name: 'Custom Pattern Policy'
          permissions: '+@read +set ~cache:*'
        }
      ]
      accessPolicyAssignments: [
        {
          objectId: nestedDependencies.outputs.managedIdentityPrincipalId
          objectIdAlias: 'dep-${namePrefix}-msi-${serviceShort}'
          accessPolicyName: 'Custom Pattern Policy'
        }
        {
          objectId: nestedDependencies.outputs.managedIdentityPrincipalId2
          objectIdAlias: 'dep-${namePrefix}-msi2-${serviceShort}'
          accessPolicyName: 'Admin Policy'
        }
      ]
    }
  }
]
