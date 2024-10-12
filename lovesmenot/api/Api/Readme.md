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
	--template-parameters "SteamWebApiKey=$env:STEAM_WEB_API_KEY;LovesMeNotJwtKey=$env:LOVESMENOT_JWT_KEY;AzureAppClientId=$env:AZURE_APP_CLIENT_ID;AzureAppSecret=$env:AZURE_APP_SECRET"

# delete lambda
dotnet lambda delete-serverless --stack-name lovesmenot-stack
```

CloudFormation:

```json
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Transform": "AWS::Serverless-2016-10-31",
  "Description": "An AWS Serverless Application that uses the ASP.NET Core framework running in Amazon Lambda.",
  "Parameters": {
    "SteamWebApiKey": {
      "Type": "String"
    },
    "LovesMeNotJwtKey": {
      "Type": "String"
    },
    "AzureAppClientId": {
      "Type": "String"
    },
    "AzureAppSecret": {
      "Type": "String"
    }
  },
  "Conditions": {},
  "Resources": {
    "AspNetCoreFunction": {
      "Type": "AWS::Serverless::Function",
      "Properties": {
        "Handler": "Api",
        "Runtime": "dotnet8",
        "CodeUri": "s3://lovesmenot-deploy/lovesmenot/AspNetCoreFunction-CodeUri-Or-ImageUri-638643528428274141-638643528485839302.zip",
        "MemorySize": 512,
        "Timeout": 30,
        "Environment": {
          "Variables": {
            "LOVESMENOT_API_URL": "https://api.lovesmenot.blint.cloud",
            "STEAM_WEB_API_KEY": {
              "Ref": "SteamWebApiKey"
            },
            "LOVESMENOT_JWT_KEY": {
              "Ref": "LovesMeNotJwtKey"
            },
            "LOVESMENOT_WEBSITE_URL": "https://lovesmenot.blint.cloud",
            "AZURE_APP_CLIENT_ID": {
              "Ref": "AzureAppClientId"
            },
            "AZURE_APP_SECRET": {
              "Ref": "AzureAppSecret"
            }
          }
        },
        "Role": {
          "Fn::Join": [
            "",
            [
              "arn:aws:iam::",
              {
                "Ref": "AWS::AccountId"
              },
              ":role/LovesMeNotLambdaRole"
            ]
          ]
        },
        "Policies": [
          "AWSLambda_FullAccess"
        ],
        "Events": {
          "ProxyResource": {
            "Type": "Api",
            "Properties": {
              "Path": "/{proxy+}",
              "Method": "ANY"
            }
          },
          "RootResource": {
            "Type": "Api",
            "Properties": {
              "Path": "/",
              "Method": "ANY"
            }
          }
        }
      }
    }
  },
  "Outputs": {
    "ApiURL": {
      "Description": "API endpoint URL for Prod environment",
      "Value": {
        "Fn::Sub": "https://lmn-api.blint.cloud"
      }
    }
  }
}
```