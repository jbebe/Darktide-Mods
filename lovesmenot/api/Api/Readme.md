Steam auth:
	https://steamcommunity.com/dev

dotnet lambda commandline params:
	https://github.com/aws/aws-extensions-for-dotnet-cli/blob/80c2ace6319aa7514731004774f4d4791878fc3e/src/Amazon.Lambda.Tools/LambdaDefinedCommandOptions.cs#L241

```bash
# deploy lambda
dotnet lambda deploy-serverless --s3-bucket lovesmenot-deploy --stack-name lovesmenot-stack --template-parameters "SteamWebApiKey=$env:STEAM_WEB_API_KEY"

# delete lambda
dotnet lambda delete-serverless --stack-name lovesmenot-stack
```