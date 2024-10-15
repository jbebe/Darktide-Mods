Steam auth:
	https://steamcommunity.com/dev
	https://steamcommunity.com/dev/apikey

dotnet lambda commandline params:
	https://github.com/aws/aws-extensions-for-dotnet-cli/blob/80c2ace6319aa7514731004774f4d4791878fc3e/src/Amazon.Lambda.Tools/LambdaDefinedCommandOptions.cs#L241

```bash
# deploy lambda

dotnet lambda deploy-serverless `
	--s3-bucket lovesmenot-deploy `
	--stack-name lovesmenot-stack `
	--template-parameters "SteamWebApiKey=$env:STEAM_WEB_API_KEY;LovesMeNotJwtKey=$env:LOVESMENOT_JWT_KEY;LovesMeNotJwtPublicKey=$env:LOVESMENOT_JWT_PUBLIC_KEY;AzureAppClientId=$env:AZURE_APP_CLIENT_ID;AzureAppSecret=$env:AZURE_APP_SECRET"

# delete lambda
dotnet lambda delete-serverless --stack-name lovesmenot-stack
```

LovesMeNotLambdaRole:
    LovesMeNotLambdaPolicy:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeTable",
                "dynamodb:BatchGetItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:eu-west-1:970547337797:table/lovesmenot"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:eu-west-1:970547337797:*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        }
    ]
}
```

Api Gateway:
    Private IP policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "execute-api:/*/*/*",
            "Condition" : {
                "NotIpAddress": {
                    "aws:SourceIp": [ 
                        "173.245.48.0/20",
                        "103.21.244.0/22",
                        "103.22.200.0/22",
                        "103.31.4.0/22",
                        "141.101.64.0/18",
                        "108.162.192.0/18",
                        "190.93.240.0/20",
                        "188.114.96.0/20",
                        "197.234.240.0/22",
                        "198.41.128.0/17",
                        "162.158.0.0/15",
                        "104.16.0.0/13",
                        "104.24.0.0/14",
                        "172.64.0.0/13",
                        "131.0.72.0/22",
                        "2400:cb00::/32",
                        "2606:4700::/32",
                        "2803:f800::/32",
                        "2405:b500::/32",
                        "2405:8100::/32",
                        "2a06:98c0::/29",
                        "2c0f:f248::/32"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "execute-api:/*/*/*"
        }
    ]
}
```
