var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

// AWS Lambda specific line; if removed, practically portable
builder.Services.AddAWSLambdaHosting(LambdaEventSource.RestApi);

var app = builder.Build();
app.UseHttpsRedirection();
app.MapControllers();
app.MapGet("/", () => "API server for 'Loves Me, Loves Me Not' Darktide mod");
app.Run();

namespace Api { public partial class Program { } }