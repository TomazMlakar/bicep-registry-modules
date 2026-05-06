// ================ //
// Parameters       //
// ================ //

@description('Required. Name of the resource.')
param name string

@allowed([
  'C0'
  'C1'
  'F0'
  'PES'
])
@description('Required. The name of the Azure Health Bot SKU.')
param sku string

import { managedIdentityOnlyUserAssignedType } from 'br/public:avm/utl/types/avm-common-types:0.7.0'
@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentityOnlyUserAssignedType?

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

import { customerManagedKeyWithAutoRotateType } from 'br/public:avm/utl/types/avm-common-types:0.6.1'
@description('Optional. The customer managed key definition.')
param customerManagedKey customerManagedKeyWithAutoRotateType?

@description('Optional. Tags of the resource.')
param tags resourceInput<'Microsoft.HealthBot/healthBots@2025-11-01'>.tags?

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: !empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : null
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

var isHSMManagedCMK = split(customerManagedKey.?keyVaultResourceId ?? '', '/')[?7] == 'managedHSMs'

resource cMKKeyVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = if (!empty(customerManagedKey) && !isHSMManagedCMK) {
  name: last(split((customerManagedKey.?keyVaultResourceId!), '/'))
  scope: resourceGroup(
    split(customerManagedKey.?keyVaultResourceId!, '/')[2],
    split(customerManagedKey.?keyVaultResourceId!, '/')[4]
  )

  resource cMKKey 'keys@2025-05-01' existing = if (!empty(customerManagedKey) && !isHSMManagedCMK) {
    name: customerManagedKey.?keyName!
  }
}

resource cMKUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = if (!empty(customerManagedKey.?userAssignedIdentityResourceId)) {
  name: last(split(customerManagedKey.?userAssignedIdentityResourceId!, '/'))
  scope: resourceGroup(
    split(customerManagedKey.?userAssignedIdentityResourceId!, '/')[2],
    split(customerManagedKey.?userAssignedIdentityResourceId!, '/')[4]
  )
}

resource healthBot 'Microsoft.HealthBot/healthBots@2025-11-01' = {
  name: name
  location: location
  tags: tags
  identity: identity
  sku: {
    name: sku
  }
  properties: {
    keyVaultProperties: !empty(customerManagedKey)
      ? {
          keyName: customerManagedKey!.keyName
          keyVaultUri: !isHSMManagedCMK
            ? cMKKeyVault!.properties.vaultUri
            : 'https://${last(split((customerManagedKey!.keyVaultResourceId), '/'))}.managedhsm.azure.net/'
          keyVersion: !empty(customerManagedKey.?keyVersion)
            ? customerManagedKey!.keyVersion!
            : (customerManagedKey.?autoRotationEnabled ?? true)
                ? null
                : (!isHSMManagedCMK
                    ? last(split(cMKKeyVault::cMKKey!.properties.keyUriWithVersion, '/'))
                    : fail('Managed HSM CMK encryption requires either specifying the \'keyVersion\' or omitting the \'autoRotationEnabled\' property. Setting \'autoRotationEnabled\' to false without a \'keyVersion\' is not allowed.'))
          userIdentity: !empty(customerManagedKey.?userAssignedIdentityResourceId) ? cMKUserAssignedIdentity.id : null
        }
      : null
  }
}
