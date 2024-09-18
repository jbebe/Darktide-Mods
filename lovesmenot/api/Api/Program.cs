using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Api.Controllers.Models;
using Api.Database;
using Api.Services;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<IDynamoDBContext>(services => new DynamoDBContext(new AmazonDynamoDBClient()));
builder.Services.AddSingleton<IDatabaseService, DynamoDbService>();
builder.Services.AddSingleton<RatingsService>();

// AWS Lambda specific line; if removed, practically portable
builder.Services.AddAWSLambdaHosting(LambdaEventSource.RestApi);

var app = builder.Build();
app.MapGet("/", () => "Loves Me, Loves Me Not 🌸");
app.MapGet("/ratings/{region}", ([FromRoute] string region, RatingsService ratingsService, CancellationToken cancellationToken)
    => ratingsService.GetRatingsAsync(region, cancellationToken));
app.MapPost("/ratings/{region}", ([FromRoute] string region, [FromBody] RatingRequest request, RatingsService ratingsService)
    => ratingsService.UpdateRatingAsync(region, request, CancellationToken.None));

app.Run();

public partial class Program { }