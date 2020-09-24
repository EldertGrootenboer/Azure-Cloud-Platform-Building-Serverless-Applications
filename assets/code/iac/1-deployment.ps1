# What we will be doing in this script.
#   1. Create an app registration used for authentication between Logic Apps and Event Grid
#   1. Create a resource group
#   2. Deploy Azure services

# Update these according to the environment
$subscriptionName = "Visual Studio Enterprise"
$resourceGroupName = "rg-building-serverless-applications"
$appRegistrationName = "sp-building-serverless-applications-event-grid"
$administratorEmail = "me@eldert.net"
$basePath = "C:\Users\elder\OneDrive\Sessions\Azure-s-Cloud-Platform-Building-Serverless-Applications"

# Login to Azure
Get-AzSubscription -SubscriptionName $subscriptionName | Set-AzContext

# Retrieves the dynamic parameters
$administratorObjectId = (Get-AzADUser -Mail $administratorEmail).Id

# If the app registration doesn't exist, we will create one
$appRegistration = Get-AzADApplication -DisplayName $appRegistrationName
if(-not $appRegistration)
{
    # Create app registration
    $appRegistration = New-AzADApplication -DisplayName $appRegistrationName -IdentifierUris "http://$appRegistrationName"

    # Create client secret
    $bytes = New-Object Byte[] 32
    ([System.Security.Cryptography.RandomNumberGenerator]::Create()).GetBytes($bytes)
    $clientSecret = [System.Convert]::ToBase64String($bytes) | ConvertTo-SecureString -AsPlainText -Force
    $endDate = [System.DateTime]::Now.AddYears(5)
    New-AzADAppCredential -ObjectId $appRegistration.ObjectId -Password $clientSecret -EndDate $endDate
}

# Create the resource group and deploy the resources
New-AzResourceGroup -Name $resourceGroupName -Location 'West Europe' -Tag @{CreationDate=[DateTime]::UtcNow.ToString(); Project="Azure-s-Cloud-Platform-Building-Serverless-Applications"; Purpose="Session"}
New-AzResourceGroupDeployment -Name "BuildServerlessApps" -ResourceGroupName $resourceGroupName -TemplateFile "$basePath\assets\code\iac\azuredeploy.json" -administratorObjectId $administratorObjectId -servicePrincipalPasswordEventGrid $clientSecret -servicePrincipalClientIdEventGrid $appRegistration.ApplicationId

# Deploy contents of the App Service
dotnet publish "$basePath\assets\code\pgp-encryptor\Azure-s-Cloud-Platform-Building-Serverless-Applications.csproj" -c Release -o "$basePath\assets\code\pgp-encryptor\publish"
Compress-Archive -Path "$basePath\assets\code\pgp-encryptor\publish\*" -DestinationPath "$basePath\assets\code\pgp-encryptor\Deployment.zip"
Publish-AzWebapp -ResourceGroupName $resourceGroupName -Name $appServiceName -ArchivePath "$basePath\assets\code\pgp-encryptor\Deployment.zip"
Remove-Item "$basePath\assets\code\pgp-encryptor\Deployment.zip"

# Optional for debugging, loops through each local file individually
#Get-ChildItem "$basePath\assets\code\iac" -Filter *.json | 
#Foreach-Object {
#    Write-Output "Deploying: " $_.FullName
#    New-AzResourceGroupDeployment -Name Demo -ResourceGroupName $resourceGroupName -TemplateFile $_.FullName -ErrorAction Continue
#}