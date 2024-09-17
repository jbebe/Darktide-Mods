using Api.Controllers;
using Api.Services;

namespace Api
{
    public class Program 
    { 
        public static int Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            builder.Services.AddSingleton<RatingsService>();
            
            // AWS Lambda specific line; if removed, practically portable
            builder.Services.AddAWSLambdaHosting(LambdaEventSource.RestApi);

            var app = builder.Build();
            app.MapGet("/", () => "Loves Me, Loves Me Not 🌸");
            app.MapGet("/ratings", RatingsController.GetRatingsAsync);
            app.MapPost("/ratings", RatingsController.AddRatingAsync);

            app.Run();

            return 0;
        }
    }
}
