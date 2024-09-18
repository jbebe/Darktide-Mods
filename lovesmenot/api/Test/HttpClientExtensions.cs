using Api.Controllers.Models;
using System.Net.Http.Json;

namespace Test
{
    internal static class HttpClientExtensions
    {
        public static async Task<RatingRequest> CreateRatingAsync(
            this HttpClient client, string region, RatingRequest request, CancellationToken cancellationToken)
        {
            var response = await client.PostAsJsonAsync($"/ratings/{region}", request, cancellationToken);
            response.EnsureSuccessStatusCode();

            return request;
        }

        public static async Task<List<RatingResponse>> GetRatingsAsync(
            this HttpClient client, string region, CancellationToken cancellationToken)
        {
            var response = await client.GetAsync($"/ratings/{region}", cancellationToken);
            response.EnsureSuccessStatusCode();

            var ratings = new List<RatingResponse>();
            var body = response.Content.ReadFromJsonAsAsyncEnumerable<RatingResponse>(cancellationToken);
            await foreach (var rating in body) ratings.Add(rating!);

            return ratings;
        }
    }
}
