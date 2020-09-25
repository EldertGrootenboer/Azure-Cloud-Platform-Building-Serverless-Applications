# What we will be doing in this script.
#   1. Create an app registration used for authentication between Logic Apps and Event Grid
#   2. Create a resource group
#   3. Deploy Azure services

# Update these according to the environment
$subscriptionName = "Visual Studio Enterprise"
$resourceGroupName = "rg-building-serverless-applications-6"
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
New-AzResourceGroup -Name $resourceGroupName -Location 'West Europe' -Tag @{CreationDate=[DateTime]::UtcNow.ToString(); Project="Azure’s Cloud Platform - Building Serverless Applications"; Purpose="Session"}
New-AzResourceGroupDeployment -Name "BuildServerlessApps1" -ResourceGroupName $resourceGroupName -TemplateFile "$basePath\assets\code\iac\azuredeploy.1.json" -administratorObjectId $administratorObjectId -servicePrincipalPasswordEventGrid $clientSecret

# Deploy contents of the Function
dotnet publish "$basePath\assets\code\pgp-encryptor\Azure-s-Cloud-Platform-Building-Serverless-Applications.csproj" -c Release -o "$basePath\assets\code\pgp-encryptor\publish"
Compress-Archive -Path "$basePath\assets\code\pgp-encryptor\publish\*" -DestinationPath "$basePath\assets\code\pgp-encryptor\Deployment.zip"
$functionApp = Get-AzResource -ResourceGroupName $resourceGroupName -Name func-*
Publish-AzWebapp -ResourceGroupName $resourceGroupName -Name $functionApp.Name -ArchivePath "$basePath\assets\code\pgp-encryptor\Deployment.zip"
Remove-Item "$basePath\assets\code\pgp-encryptor\Deployment.zip"

# Deploy event grid API and contract  processing Logic App
# Can not be done from first orchestrator as they needs specific other resources to first be deployed
New-AzResourceGroupDeployment -Name "BuildServerlessApps2" -ResourceGroupName $resourceGroupName -TemplateFile "$basePath\assets\code\iac\azuredeploy.2.json" -servicePrincipalClientIdEventGrid $appRegistration.ApplicationId

# Optional for debugging, loops through each local file individually
#Get-ChildItem "$basePath\assets\code\iac" -Filter *.json | 
#Foreach-Object {
#    Write-Output "Deploying: " $_.FullName
#    New-AzResourceGroupDeployment -Name Demo -ResourceGroupName $resourceGroupName -TemplateFile $_.FullName -ErrorAction Continue
#}