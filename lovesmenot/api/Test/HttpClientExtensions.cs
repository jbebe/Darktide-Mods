using Api.Controllers.Models;
using System.Net.Http.Json;

namespace Test
{
    internal static class HttpClientExtensions
    {
        public static async Task<RatingRequest> CreateRatingAsync(
            this HttpClient client, RatingRequest request, CancellationToken cancellationToken)
        {
            var response = await client.PostAsJsonAsync("/ratings", request, cancellationToken);
            response.EnsureSuccessStatusCode();

            return request;
        }

        public static async Task<List<RatingResponse>> GetRatingsAsync(
            this HttpClient client, CancellationToken cancellationToken)
        {
            var response = await client.GetAsync("/ratings", cancellationToken);
            response.EnsureSuccessStatusCode();

            var ratings = new List<RatingResponse>();
            var body = response.Content.ReadFromJsonAsAsyncEnumerable<RatingResponse>(cancellationToken);
            await foreach (var rating in body)
            {
                ratings.Add(rating!);
            }

            return ratings;
        }
    }
}
