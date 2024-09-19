using Api.Database;
using Api.Services.Models;

namespace Test
{
    internal class MockRating : IRating
    {
        public string EntityType => string.Empty;

        public required string Id {get;init;}
        
        public required DateTime Created {get;init;}
        
        public required Metadata Metadata {get;init;}
        
        public required List<Rater> RatedBy {get;init;}
        
        public DateTime? Updated { get; set; }
    }

    internal class MockDatabaseService : IDatabaseService
    {
        public Dictionary<string, MockRating> Db = [];

        public IRating CreateEntity(string id, List<Rater> ratedBy, Metadata metadata)
        {
            return new MockRating
            {
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
                Db[rating.Id] = mockRating;
            }
            else
            {
                throw new ArgumentException();
            }

            return Task.CompletedTask;
        }

        public Task<IRating?> GetRatingAsync(string id, CancellationToken cancellationToken)
        {
            Db.TryGetValue(id, out var rating);
            return Task.FromResult<IRating?>(rating);
        }

        public Task<List<IRating>> GetRatingsAsync(CancellationToken cancellationToken)
        {
            return Task.FromResult(Db.Values.Cast<IRating>().ToList());
        }
    }
}
