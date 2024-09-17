using Api.Controllers.Models;
using Api.Services;
using Microsoft.AspNetCore.Mvc;
using System.Runtime.CompilerServices;

namespace Api.Controllers
{
    public static class RatingsController
    {
        public static async IAsyncEnumerable<RatingResponse> GetRatingsAsync(
            RatingsService ratingsService, [EnumeratorCancellation] CancellationToken cancellationToken)
        {
            await foreach (var (positive, negative) in ratingsService.GetRatingsAsync(cancellationToken))
            {
                yield return new RatingResponse
                {
                    Hash = (positive ?? negative!).Id,
                    Type = positive != null ? RatingType.Positive : RatingType.Negative,
                };
            }
        }

        public static async Task AddRatingAsync(RatingsService ratingsService, [FromBody] RatingRequest request)
        {
            await ratingsService.AddRatingAsync(request, CancellationToken.None);
        }
    }
}