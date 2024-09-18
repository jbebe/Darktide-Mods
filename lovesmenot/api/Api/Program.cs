using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Amazon.DynamoDBv2.DocumentModel;
using Api;
using Api.Controllers.Models;
using Api.Database;
using Api.Services;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<IDynamoDBContext>(services =>
{
    var client = new AmazonDynamoDBClient();
    var context = new DynamoDBContext(client);
    context.ConverterCache.Add(typeof(DynamoDbEnumConverter<RatingType>), new DynamoDbEnumConverter<RatingType>());
    return context;
});
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

public class DynamoDbEnumConverter<T> : IPropertyConverter where T : struct
{
    public DynamoDBEntry ToEntry(object value)
    {
        return new Primitive
        {
            Value = Enum.Format(typeof(T), value, "G")
        };
    }

    public object FromEntry(DynamoDBEntry entry)
    {
        var enumValue = (entry as Primitive)?.Value as string;
        if (enumValue == null)
            throw new ArgumentException("Invalid entry to convert to enum");

        return Enum.Parse<T>(enumValue);
    }
}