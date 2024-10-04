using Api.Database;
using Api.Services;
using Api.Services.Models;

namespace Test
{
    internal class MockRating : IRating
    {
        public string EntityType => string.Empty;

        public required string Id {get;init;}
        
        public required DateTime Created {get;init;}
        
        public required Dictionary<string, Rater> Ratings {get;init;}
        
        public DateTime? Updated { get; set; }
    }

    internal class MockAccount : IAccount
    {
        public string EntityType => string.Empty;

        public required string Id { get; init; }

        public int CharacterLevel { get; set; }

        public required HashSet<string> Reefs { get; set; }

        public required HashSet<string> Friends { get; set; }

        public required DateTime Created { get; init; }

        public DateTime? Updated { get; set; }
    }

    internal class MockDatabaseService : IDatabaseService
    {
        public Dictionary<string, MockAccount> AccountsDb = [];
        
        public Dictionary<string, MockRating> RatingsDb = [];

        public void Clear()
        {
            AccountsDb.Clear();
            RatingsDb.Clear();
        }

        public IAccount CreateAccount(string id, int characterLevel, string reef, string[] friends, DateTime created)
        {
            return new MockAccount
            {
                Id = id,
                CharacterLevel = characterLevel,
                Reefs = [reef],
                Friends = new HashSet<string>(friends),
                Created = created,
            };
        }

        public IRating CreateRating(string id, Dictionary<string, Rater> ratings, DateTime created)
        {
            return new MockRating
            {
                Id = id,
                Ratings = ratings,
                Created = created,
            };
        }

        public Task CreateOrUpdateAccountAsync(IAccount entity, CancellationToken cancellationToken)
        {
            AccountsDb[entity.Id] = (MockAccount)entity;
            return Task.CompletedTask;
        }

        public Task CreateOrUpdateRatingAsync(IRating entity, CancellationToken cancellationToken)
        {
            RatingsDb[entity.Id] = (MockRating)entity;
            return Task.CompletedTask;
        }

        public Task<IAccount?> GetAccountAsync(string id, CancellationToken cancellationToken)
        {
            return Task.FromResult(AccountsDb.TryGetValue(id, out var account) ? (IAccount)account : null);
        }

        public Task<IRating?> GetRatingAsync(string id, CancellationToken cancellationToken)
        {
            return Task.FromResult(RatingsDb.TryGetValue(id, out var rating) ? (IRating)rating : null);
        }

        public Task<List<IRating>> GetRatingsAsync(CancellationToken cancellationToken)
        {
            return Task.FromResult(RatingsDb.Values.Cast<IRating>().ToList());
        }
    }
}
