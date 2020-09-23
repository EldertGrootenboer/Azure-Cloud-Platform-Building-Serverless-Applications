$basePath = "C:\Users\elder\OneDrive\Sessions\Azure-s-Cloud-Platform-Building-Serverless-Applications"

# Deploy contents of the App Service
dotnet publish "$basePath\assets\code\pgp-encryptor\Azure-s-Cloud-Platform-Building-Serverless-Applications.csproj" -c Release -o "$basePath\assets\code\pgp-encryptor\publish"
Compress-Archive -Path "$basePath\assets\code\pgp-encryptor\publish\*" -DestinationPath "$basePath\assets\code\pgp-encryptor\Deployment.zip"
Publish-AzWebapp -ResourceGroupName $resourceGroupName -Name $appServiceName -ArchivePath "$basePath\assets\code\pgp-encryptor\Deployment.zip"
Remove-Item "$basePath\assets\code\pgp-encryptor\Deployment.zip"