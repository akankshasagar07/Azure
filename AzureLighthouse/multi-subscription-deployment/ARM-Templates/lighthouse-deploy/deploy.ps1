[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $subscriptionId
)

Write-Host "Debug Information:"
Write-Host "Subscription ID: $subscriptionId"
#Write-Host "Working Directory: $workingDirectory"
#$dirContents = Get-ChildItem -Path "$(Get-Location)"

$deploymentName = "Multi-sub-deployment"
$deploymentLocation = "eastus2"

$templateFile = "${env:SYSTEM_DEFAULTWORKINGDIRECTORY}/_EpturaAZLHtest-CI-NEW/drop/ARM-Templates/lighthouse-deploy/azuredeploy.json"
$templateParameterFile = "${env:SYSTEM_DEFAULTWORKINGDIRECTORY}/_EpturaAZLHtest-CI-NEW/drop/ARM-Templates/lighthouse-deploy/azuredeploy.parameters.json"


Write-Output "Current working directory: $(Get-Location)"


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
        

        Write-Host "Template file path: $templateFile"
        Write-Host "Parameter file path: $templateParameterFile"

        Write-Output $dirContents
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