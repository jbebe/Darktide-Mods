using Api.Services;
using Api.Services.Models;
using System.Runtime.CompilerServices;

namespace Test
{
    internal class MockDatabaseService : IDatabaseService
    {
        public Dictionary<string, Rating> Db = [];

        public Task CreateOrUpdateAsync(Rating rating, CancellationToken cancellationToken)
        {
            Db[rating.Id] = rating;
            return Task.CompletedTask;
        }

        public Task<Rating?> GetRatingAsync(string id, CancellationToken cancellationToken)
        {
            Db.TryGetValue(id, out var rating);
            return Task.FromResult(rating);
        }

#pragma warning disable CS1998
        public async IAsyncEnumerable<Rating> GetRatingsAsync([EnumeratorCancellation] CancellationToken cancellationToken)
#pragma warning restore CS1998
        {
            foreach (var rating in Db.Values)
            {
                yield return rating;
            }
        }
    }
}
