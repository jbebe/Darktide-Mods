using Api.Services;
using Api.Services.Models;

namespace Test
{
    internal class MockDatabaseService : IDatabaseService
    {
        public Task CreateOrUpdateAsync(Rating rating, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }

        public Task<Rating?> GetRatingAsync(string id, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }

        public IAsyncEnumerable<Rating> GetRatingsAsync(CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }
}
