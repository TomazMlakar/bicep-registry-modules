metadata name = 'Event Subscriptions'
metadata description = 'This module deploys an Event Subscription.'

@description('Conditional. The name of the parent EventGrid namespace. Required if the template is used in a standalone deployment.')
param namespaceName string

@description('Conditional. The name of the parent EventGrid namespace topic. Required if the template is used in a standalone deployment.')
param topicName string

@description('Required. Name of the Event Subscription to create.')
param name string

@description('Optional. Information about the delivery configuration of the Event Subscription.')
param deliveryConfiguration object?

@description('Optional. The event delivery schema for the Event Subscription.')
param eventDeliverySchema string = 'CloudEventSchemaV1_0'

@description('Optional. Information about the filter for the Event Subscription.')
param filtersConfiguration object?

import { roleAssignmentType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType[]?

var builtInRoleNames = {
  'Azure Resource Notifications System Topics Subscriber': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0b962ed2-6d56-471c-bd5f-3477d83a7ba4'
  )
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  'EventGrid Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '1e241071-0855-49ea-94dc-649edcd759de'
  )
  'EventGrid Data Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '1d8c3fe3-8864-474b-8749-01e3783e8157'
  )
  'EventGrid Data Receiver': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '78cbd9e7-9798-4e2e-9b5a-547d9ebb31fb'
  )
  'EventGrid Data Sender': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'd5a91429-5739-47e2-a06b-3470a27159e7'
  )
  'EventGrid EventSubscription Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '428e0ff0-5e57-4d9c-a221-2c70d0e0a443'
  )
  'EventGrid EventSubscription Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '2414bbcf-6497-4faf-8c65-045460748405'
  )
  'EventGrid TopicSpaces Publisher': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'a12b0b94-b317-4dcd-84a8-502ce99884c6'
  )
  'EventGrid TopicSpaces Subscriber': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '4b0f2fd7-60b4-4eca-896f-4435034f8bf5'
  )
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
}

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

// ============== //
// Resources      //
// ============== //

resource namespace 'Microsoft.EventGrid/namespaces@2023-12-15-preview' existing = {
  name: namespaceName

  resource topic 'topics@2023-12-15-preview' existing = {
    name: topicName
  }
}

resource eventSubscription 'Microsoft.EventGrid/namespaces/topics/eventSubscriptions@2023-12-15-preview' = {
  name: name
  parent: namespace::topic
  properties: {
    deliveryConfiguration: deliveryConfiguration
    eventDeliverySchema: eventDeliverySchema
    filtersConfiguration: filtersConfiguration
  }
}

resource eventSubscription_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(
      eventSubscription.id,
      roleAssignment.principalId,
      roleAssignment.roleDefinitionId
    )
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: eventSubscription
  }
]

// ============ //
// Outputs      //
// ============ //

// Add your outputs here

@description('The resource ID of the Event Subscription.')
output resourceId string = eventSubscription.id

@description('The name of the Event Subscription.')
output name string = eventSubscription.name

@description('The name of the resource group the Event Subscription was created in.')
output resourceGroupName string = resourceGroup().name
