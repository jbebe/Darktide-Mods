using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Api.Database.Models;
using Api.Services;
using Api.Services.Models;

namespace Api.Database
{
    internal class DynamoDbService : IDatabaseService
    {
        public IDynamoDBContext Context { get; }

        public DynamoDbService(IDynamoDBContext context)
        {
            Context = context;
        }

        public IRating CreateRating(string id, Dictionary<string, Rater> ratings, DateTime created)
        {
            return new DynamoDbRating
            {
                EntityType = DynamoDbRating.HashKey,
                Id = id,
                Ratings = ratings,
                Created = created,
            };
        }

        public IAccount CreateAccount(string id, int characterLevel, string reef, string[] friends, DateTime created)
        {
            return new DynamoDbAccount
            {
                EntityType= DynamoDbAccount.HashKey,
                Id = id,
                CharacterLevel = characterLevel,
                Reefs = [reef],
                Friends = new HashSet<string>(friends),
                Created = created,
            };
        }

        public async Task CreateOrUpdateRatingAsync(IRating entity, CancellationToken cancellationToken)
        {
            if (entity is DynamoDbRating rating)
            {
                await CreateOrUpdateAsync(rating, cancellationToken);
            }
            throw new ArgumentException("Invalid type", nameof(entity));
        }

        public async Task CreateOrUpdateAccountAsync(IAccount entity, CancellationToken cancellationToken)
        {
            if (entity is DynamoDbAccount account)
            {
                await CreateOrUpdateAsync(account, cancellationToken);
            }
            throw new ArgumentException("Invalid type", nameof(entity));
        }

        public async Task<IRating?> GetRatingAsync(string id, CancellationToken cancellationToken)
            => await GetEntityAsync<DynamoDbRating>(DynamoDbRating.HashKey, id, cancellationToken);

        public async Task<IAccount?> GetAccountAsync(string id, CancellationToken cancellationToken)
            => await GetEntityAsync<DynamoDbAccount>(DynamoDbAccount.HashKey, id, cancellationToken);

        public async Task<List<IRating>> GetRatingsAsync(CancellationToken cancellationToken)
            => await GetEntitiesAsync<DynamoDbRating, IRating>(DynamoDbRating.HashKey, cancellationToken);

        private async Task CreateOrUpdateAsync<T>(T entity, CancellationToken cancellationToken) where T : BaseEntity
        {
            await Context.SaveAsync(entity, cancellationToken);
        }

        private async Task<T?> GetEntityAsync<T>(string hashValue, string sortValue, CancellationToken cancellationToken) where T : BaseEntity
        {
            try
            {
                return await Context.LoadAsync<T>(hashValue, sortValue, cancellationToken);
            }
            catch (AmazonDynamoDBException)
            {
                return null;
            }

            // throws if different error
        }

        private async Task<List<TIface>> GetEntitiesAsync<TEntity, TIface>(string hashValue, CancellationToken cancellationToken)
            where TEntity : IEntity, TIface
        {
            var search = Context.QueryAsync<TEntity>(hashValue);
            var results = await search.GetRemainingAsync(cancellationToken);
            return results.Cast<TIface>().ToList();
        }
    }
}
