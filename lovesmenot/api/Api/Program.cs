using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Api;
using Api.Controllers.Models;
using Api.Database;
using Api.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.Text.Json;
using System.Text.Json.Serialization;
using JsonOptions = Microsoft.AspNetCore.Http.Json.JsonOptions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<JsonOptions>(options =>
    options.SerializerOptions.Converters.Add(
        new JsonStringEnumConverter(JsonNamingPolicy.CamelCase)));

builder.Services
    .AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/login";
        options.LogoutPath = "/signout";
    })
    .AddSteam(options =>
    {
        options.ApplicationKey = Constants.Auth.SteamWebApiKey;
    })
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = Constants.Auth.JwtIssuer,
            IssuerSigningKey = Constants.Auth.JwtKeyObject,
        };
    });

var authPolicy = new AuthorizationPolicyBuilder()
    .AddAuthenticationSchemes(JwtBearerDefaults.AuthenticationScheme)
    .RequireAuthenticatedUser()
    .Build();
builder.Services.AddAuthorizationBuilder().SetDefaultPolicy(authPolicy);
builder.Services.AddHttpContextAccessor();

builder.Services.AddSingleton<IDynamoDBContext>(services =>
{
    var client = new AmazonDynamoDBClient();
    var context = new DynamoDBContext(client);
    context.ConverterCache.Add(typeof(RatingType), new DynamoDbEnumConverter<RatingType>());
    return context;
});
builder.Services.AddSingleton<IDatabaseService, DynamoDbService>();
builder.Services.AddSingleton<RatingsService>();
builder.Services.AddSingleton<SteamAuthService>();

// AWS Lambda specific line; if removed, practically portable
builder.Services.AddAWSLambdaHosting(LambdaEventSource.RestApi);

var app = builder.Build();
app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/", () => "Loves Me, Loves Me Not 🌸");
app.MapGet($"{Constants.ApiVersion}/ratings", (RatingsService ratingsService, CancellationToken cancellationToken)
    => ratingsService.GetRatingsAsync(cancellationToken)).RequireAuthorization(authPolicy);
app.MapPost($"{Constants.ApiVersion}/ratings", ([FromBody] RatingRequest request, RatingsService ratingsService) 
    => ratingsService.UpdateAsync(request, CancellationToken.None)).RequireAuthorization(authPolicy);
app.MapGet($"auth/steam", (SteamAuthService authService)
    => authService.ChallengeAsync());
app.MapGet($"callback/steam", (SteamAuthService authService)
    => authService.HandleCallbackAsync());

app.Run();

public partial class Program { }
