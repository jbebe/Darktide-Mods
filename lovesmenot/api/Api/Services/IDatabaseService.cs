
using Api.Services.Models;

namespace Api.Services
{
    public interface IDatabaseService
    {
        Task<Rating?> GetRatingAsync(string id, CancellationToken cancellationToken);

        IAsyncEnumerable<Rating> GetRatingsAsync(CancellationToken cancellationToken);
    }
}
