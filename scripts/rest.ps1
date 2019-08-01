$azContext = Get-AzContext

function GetContext () {
  $subscriptionName = $azContext | Select Name | tail -n 2 
  $regex = [regex]"\((.*)\)"
  $subId = [regex]::match($subscriptionName, $regex).Groups[1]
  $subIdValue = $subId.Value
  return $subIdValue
}

function GetAuthToken () {
  $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
  $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
  $token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
  $authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
  }
  return $authHeader
}

$subscriptionValue = GetContext
$authHeaders = GetAuthToken

$authHeaders

# Create the REST API
$restUri = 'https://management.azure.com/subscriptions/{0}?api-version=2016-06-01' -f $subscriptionValue

# Create the subscription REST API
$subscriptionCreateUri = 'https://management.azure.com/subscriptions/{0}/providers/Microsoft.Blueprint/blueprints/simpleBlueprint?api-version=2018-11-01-preview' -f $subscriptionValue

$subscriptionCreateUri

$params = @"
{
  "properties": {
    "description": "blueprint contains all artifact kinds {'template', 'rbac', 'policy'}",
    "parameters": {
      "storageAccountType": {
        "type": "string",
        "metadata": {
          "displayName": "storage account type."
        }
      },
      "costCenter": {
        "type": "string",
        "metadata": {
          "displayName": "force cost center tag for all resources under given subscription."
        }
      },
      "owners": {
        "type": "array",
        "metadata": {
          "displayName": "assign owners to subscription along with blueprint assignment."
        }
      }
    },
    "resourceGroups": {
      "storageRG": {
        "metadata": {
          "displayName": "storage resource group",
          "description": "Contains storageAccounts that collect all shoebox logs."
        }
      }
    },
    "targetScope": "subscription"
  }
}
"@

$response = Invoke-RestMethod -Uri $subscriptionCreateUri -Method Put -Headers $authHeaders -Body $params
$response | ConvertTo-Json