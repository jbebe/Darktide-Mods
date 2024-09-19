using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Amazon.DynamoDBv2.DocumentModel;
using Api;
using Api.Controllers.Models;
using Api.Database;
using Api.Services;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using System.Text.Json.Serialization;
using JsonOptions = Microsoft.AspNetCore.Http.Json.JsonOptions;

var builder = WebApplication.CreateBuilder(args);
builder.Services.Configure<JsonOptions>(options => 
    options.SerializerOptions.Converters.Add(
        new JsonStringEnumConverter(JsonNamingPolicy.CamelCase)));
builder.Services.AddSingleton<IDynamoDBContext>(services =>
{
    var client = new AmazonDynamoDBClient();
    var context = new DynamoDBContext(client);
    context.ConverterCache.Add(typeof(RatingType), new DynamoDbEnumConverter<RatingType>());
    return context;
});
builder.Services.AddSingleton<IDatabaseService, DynamoDbService>();
builder.Services.AddSingleton<RatingsService>();

// AWS Lambda specific line; if removed, practically portable
builder.Services.AddAWSLambdaHosting(LambdaEventSource.RestApi);

var app = builder.Build();
app.MapGet("/", () => "Loves Me, Loves Me Not 🌸");
app.MapGet("/ratings", (RatingsService ratingsService, CancellationToken cancellationToken)
    => ratingsService.GetRatingsAsync(cancellationToken));
app.MapPost("/ratings", ([FromBody] RatingRequest request, RatingsService ratingsService)
    => ratingsService.UpdateRatingAsync(request, CancellationToken.None));

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