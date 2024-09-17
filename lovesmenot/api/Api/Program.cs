using Api.Controllers.Models;
using Api.Services;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<RatingsService>();

// AWS Lambda specific line; if removed, practically portable
builder.Services.AddAWSLambdaHosting(LambdaEventSource.RestApi);

var app = builder.Build();
app.MapGet("/", () => "Loves Me, Loves Me Not 🌸");
app.MapGet("/ratings", (RatingsService ratingsService, CancellationToken cancellationToken)
    => ratingsService.GetRatingsAsync(cancellationToken));
app.MapPost("/ratings", (RatingsService ratingsService, [FromBody] RatingRequest request)
    => ratingsService.AddRatingAsync(request, CancellationToken.None));

app.Run();

public partial class Program { }