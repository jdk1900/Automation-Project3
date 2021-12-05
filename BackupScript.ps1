$currentsub = Select-AzSubscription -Subscription ${env:SUBSCRIPTION_ID}
$SubscriptionName = $currentsub.Name
$setdate = Get-Date -Format dd-MM-yyyy

try {
    $allapplicationGateways = Get-AzApplicationGateway
}
catch {
    #if application gateways not found,display the following message:
    throw "Couldn't find any Application Gateways in subscription: $SubscriptionName"
}

Write-Host 'In the Subscription' $SubscriptionName $allapplicationGateways.Count''Application Gateways' found.'
$activeAppGws = 0
$stoppedAppGws = 0
$i = 0

#Check the Operational state for each Application Gateway.
#We use the variables stoppedAppGws and activeAppGws to store the number of the active Application Gateways and publish them (see line 92,93)
ForEach ($appGateway in $allapplicationGateways) {
    $state = $appGateway.OperationalState
    if ($state -eq "Stopped") 
    {
            $stoppedAppGws++
        }
        else {
            $activeAppGws++
    }


    $i = $i + 1

    #We will store json files in a container, so each json file needs to be in lowercase (containers accepts only lowercase)
    $resourceName = $appGateway.Name
    $resourceName = $resourceName.ToLower()

    #Get the RG name and id from each Application Gateway
    $ResourceGroupName = $appGateway.ResourceGroupName
    $resourceId = $appGateway.Id

    #Publish some details:
    Write-Host 'Application Gateway No:' $i 'is' $resourceName 'in' $ResourceGroupName 'and the Operational state is:' $state

    #Specify the name of the json file and path
    $exportfileName = "$resourceName-$setdate.json"
    $exportpathlocation = "C\temp\$exportfileName"

    #export current application gateway to a json file
    try {
        Write-Information "Now Executing export for Application Gateway: $ResourceName"
        Export-AzResourceGroup -ResourceGroupName $ResourceGroupName `
                               -Resource $resourceId `
                               -Path $exportpathlocation `
                               -IncludeParameterDefaultValue `
                               -Confirm:$false `
                               -Force
    } catch {
        throw $_
    }


    #Get Storage account
try {
    $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name ${env:STORAGE_ACCOUNT_NAME}
    $storageAccountContext = $storageAccount.context
    Write-Information "storage account found:" ${env:STORAGE_ACCOUNT_NAME}
}
catch {
    Write-Error "No storage account found with the name:" ${env:STORAGE_ACCOUNT_NAME}
}
    #Get the Container
try {

    Get-AzStorageContainer -Name ${env:CONTAINER_NAME} -Context $storageAccountContext
}
catch {
    Write-Output "container not found"
}


    # Upload backup to Storage Account
    try {
        Write-Information "Now Uploading backup file to Azure..."
        Set-AzStorageBlobContent -File $exportpathlocation `
                                 -Container ${env:CONTAINER_NAME} `
                                 -Blob $exportfileName `
                                 -Context $storageAccountContext 
    } catch {
        throw $_
    }
}
Write-Host 'Application/s Gateways stopped in total:' $stoppedAppGws
Write-Host 'Application/s Gateways started in total:' $activeAppGws