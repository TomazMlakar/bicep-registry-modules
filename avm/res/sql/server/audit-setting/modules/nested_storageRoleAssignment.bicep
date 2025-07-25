param storageAccountName string
param managedIdentityPrincipalId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: storageAccountName
}

// Assign Storage Blob Data Contributor RBAC role
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${storageAccount.id}-${managedIdentityPrincipalId}-Storage-Blob-Data-Contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    )
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}
