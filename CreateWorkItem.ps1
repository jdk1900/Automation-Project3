#Authentication in Azure DevOps
$AzureDevOpsPAT = 'sdfjlskdjflsdfkbkejbe43525fksdfkjn'
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

$OrganizationName = "dimitriskrallis0042"
$UriOrganization = "https://dev.azure.com/$($OrganizationName)/"

#Lists all projects in your organization
$uriAccount = $UriOrganization + "_apis/projects?api-version=5.1"
Invoke-RestMethod -Uri $uriAccount -Method get -Headers $AzureDevOpsAuthenicationHeader 


#Create a work item

$WorkItemType = "task"
$WorkItemTitle = "Application Gateway/s Backup"
$ProjectName = "MyBackupInfraProject";


$uri = $UriOrganization + $ProjectName + "/_apis/wit/workitems/$" + $WorkItemType + "?api-version=5.1"
echo $uri

$body="[
  {
    `"op`": `"add`",
    `"path`": `"/fields/System.Title`",
    `"value`": `"$($WorkItemTitle) completed`"
  }
]"

Invoke-RestMethod -Uri $uri -Method POST -Headers $AzureDevOpsAuthenicationHeader -ContentType "application/json-patch+json" -Body $body