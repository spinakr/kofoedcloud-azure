targetScope = 'subscription'

var roleAssignments = [
  //Key Vault Admin to Kofoed
  {
    roleDefinitionId: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
    principalId: '8b23155a-7cd1-4bed-ac73-2bfc5d4d9d37'
    principalType: 'User'
  }
  // App Config Data Owner to Kofoed
  {
    roleDefinitionId: '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'
    principalId: '8b23155a-7cd1-4bed-ac73-2bfc5d4d9d37'
    principalType: 'User'
  }
]

resource RoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for assignment in roleAssignments:{
  name: guid(subscription().id, assignment.roleDefinitionId, assignment.principalId)
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${assignment.roleDefinitionId}'
    principalId: assignment.principalId
    principalType: assignment.principalType
  }
}]
