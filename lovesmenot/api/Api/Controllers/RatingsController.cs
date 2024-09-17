using Api.Controllers.Models;
using Api.Services;
using Microsoft.AspNetCore.Mvc;
using System.Runtime.CompilerServices;

namespace Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RatingsController : ControllerBase
    {
        private ILogger<RatingsController> Logger { get; }

        private RatingsService RatingsService { get; }

        public RatingsController(ILogger<RatingsController> logger, RatingsService ratingsService)
        {
            Logger = logger;
            RatingsService = ratingsService;
        }

        [HttpGet("ratings")]
        public async IAsyncEnumerable<RatingResponse> GetRatingsAsync([EnumeratorCancellation] CancellationToken cancellationToken)
        {
            await foreach (var (positive, negative) in RatingsService.GetRatingsAsync(cancellationToken))
            {
                yield return new RatingResponse
                {
                    Hash = (positive ?? negative!).Id,
                    Type = positive != null ? RatingType.Positive : RatingType.Negative,
                };
            }
        }

        [HttpPost("ratings")]
        public async Task AddRatingAsync([FromBody] RatingRequest request)
        {
            await RatingsService.AddRatingAsync(request, CancellationToken.None);
        }
    }
}