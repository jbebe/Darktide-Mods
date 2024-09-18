using Api.Database;
using Api.Services.Models;

namespace Test
{
    internal class MockRating : IRating
    {
        public required string Region { get; init; }
        
        public required string Id {get;init;}
        
        public required DateTime Created {get;init;}
        
        public required Metadata Metadata {get;init;}
        
        public required List<Rater> RatedBy {get;init;}
        
        public DateTime? Updated { get; set; }
    }

    internal class MockDatabaseService : IDatabaseService
    {
        public Dictionary<string, MockRating> Db = [];

        public IRating CreateEntity(string region, string id, List<Rater> ratedBy, Metadata metadata)
        {
            return new MockRating
            {
                Region = region,
                Id = id,
                Created = DateTime.UtcNow,
                Metadata = metadata,
                RatedBy = ratedBy,
            };
        }

        public Task CreateOrUpdateAsync(IRating rating, CancellationToken cancellationToken)
        {
            if (rating is MockRating mockRating)
            {
                Db[rating.Region + "|" + rating.Id] = mockRating;
            }
            else
            {
                throw new ArgumentException();
            }

            return Task.CompletedTask;
        }

        public Task<IRating?> GetRatingAsync(string region, string id, CancellationToken cancellationToken)
        {
            Db.TryGetValue(region + "|" + id, out var rating);
            return Task.FromResult<IRating?>(rating);
        }

        public Task<List<IRating>> GetRatingsAsync(string region, CancellationToken cancellationToken)
        {
            return Task.FromResult(Db.Where(x => x.Key.StartsWith($"{region}|")).Select(x => (IRating)x.Value).ToList());
        }
    }
}
