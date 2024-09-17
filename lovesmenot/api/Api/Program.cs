using Api.Services;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddSingleton<RatingsService>();

// AWS Lambda specific line; if removed, practically portable
builder.Services.AddAWSLambdaHosting(LambdaEventSource.RestApi);

var app = builder.Build();
app.UseHttpsRedirection();
app.MapControllers();
app.MapGet("/", () => "Loves Me, Loves Me Not 🌸");

app.Run();

public partial class Program { }