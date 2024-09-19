using Api;
using Api.Controllers.Models;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Test
{
    internal static class HttpClientExtensions
    {
        public static Lazy<JsonSerializerOptions> JsonOptions = new(() =>
        {
            return new JsonSerializerOptions
            {
                Converters = { new JsonStringEnumConverter(JsonNamingPolicy.CamelCase) },
            };
        });

        public static async Task<RatingRequest> CreateRatingAsync(
            this HttpClient client, RatingRequest request, CancellationToken cancellationToken)
        {
            var response = await client.PostAsJsonAsync($"/{Constants.ApiVersion}/ratings", request, cancellationToken);
            response.EnsureSuccessStatusCode();

            return request;
        }

        public static async Task<Dictionary<string, RatingType>> GetRatingsAsync(
            this HttpClient client, CancellationToken cancellationToken)
        {
            var response = await client.GetAsync($"/{Constants.ApiVersion}/ratings", cancellationToken);
            response.EnsureSuccessStatusCode();
            var body = await response.Content.ReadFromJsonAsync<Dictionary<string, RatingType>>(JsonOptions.Value, cancellationToken);

            return body!;
        }
    }
}
