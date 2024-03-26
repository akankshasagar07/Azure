[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $subscriptionId
)

Write-Host "Debug Information:"

$deploymentName = "Multi-sub-deployment"
$deploymentLocation = "eastus2"
$templateFile = ".\ARM-Templates\storage-account\azuredeploy.json"
$templateParameterFile = ".\ARM-Templates\storage-account\azuredeploy.parameters.json"
#$templateFile = "$env:SYSTEM_DEFAULTWORKINGDIRECTORY/_EpturaAZLHtest-CI/drop/s/multi-subscription-deployment/ARM-Templates/storage-account/azuredeploy.json"
#$templateParameterFile = "$env:SYSTEM_DEFAULTWORKINGDIRECTORY/_EpturaAZLHtest-CI/drop/s/multi-subscription-deployment/ARM-Templates/storage-account/azuredeploy.parameters.json"
# Output the current working directory
Write-Host "Current working directory: $(Get-Location)"

# Construct the full paths to the template and parameters files
$fullTemplateFilePath = Join-Path -Path $(Get-Location) -ChildPath $templateFile
$fullTemplateParametersFilePath = Join-Path -Path $(Get-Location) -ChildPath $templateParameterFile

# Output the full paths
Write-Host "Template file path: $fullTemplateFilePath"
Write-Host "Parameters file path: $fullTemplateParametersFilePath"

# Check if the files exist at the constructed paths
if (-Not (Test-Path -Path $fullTemplateFilePath)) {
    Write-Host "Template file not found at path: $fullTemplateFilePath"
    exit 1
}
if (-Not (Test-Path -Path $fullTemplateParametersFilePath)) {
    Write-Host "Parameters file not found at path: $fullTemplateParametersFilePath"
    exit 1
}


# If you have a set of subs that never should have deployments
# But is available to the service principal
$excludedSubs = (
    "c1971bb8-c854-45e3-af71-56f7cb067bee"
)

if ($subscriptionId -eq "ALL") {

    $subscriptions = Get-AzSubscription | Where-Object { $_.Id -NotIn $excludedSubs }
    # getting all subscriptions

    Write-Output "No subscription specified. Deploying to all subscriptions" -Verbose
    foreach ($subscription in $subscriptions) {
        
        $subscriptionId = $subscription.id
        Set-AzContext -SubscriptionId $subscriptionId

        New-AzSubscriptionDeployment -Name $deploymentName -Location $deploymentLocation `
            -TemplateParameterFile $templateParameterFile -TemplateFile $templateFile
    }
}

else {
    # using specified subscription

    Write-Output "Subscription specified at pipeline. Targeting $subscriptionId" -Verbose
    Set-AzContext -SubscriptionId $subscriptionId

    New-AzSubscriptionDeployment -Name $deploymentName -Location $deploymentLocation `
        -TemplateParameterFile $templateParameterFile -TemplateFile $templateFile
}