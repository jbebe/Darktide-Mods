
using Api.Services.Models;

namespace Api.Services
{
    public interface IDatabaseService
    {
        Task CreateOrUpdateAsync(Rating rating, CancellationToken cancellationToken);

        Task<Rating?> GetRatingAsync(string id, CancellationToken cancellationToken);

        IAsyncEnumerable<Rating> GetRatingsAsync(CancellationToken cancellationToken);
    }
}
