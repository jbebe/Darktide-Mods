using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Api.Database.Models;
using Api.Services.Models;

namespace Api.Database
{
    public class DynamoDbService : IDatabaseService
    {
        public IDynamoDBContext Context { get; }

        public DynamoDbService(IDynamoDBContext context)
        {
            Context = context;
        }

        public IRating CreateEntity(string id, Dictionary<string, Rater> ratedBy, Metadata metadata)
        {
            return new DynamoDbRating
            {
                Id = id,
                Created = DateTime.UtcNow,
                Metadata = metadata,
                RatedBy = ratedBy
            };
        }

        public async Task CreateOrUpdateAsync(IRating rating, CancellationToken cancellationToken)
        {
            await Context.SaveAsync(typeof(DynamoDbRating), rating, cancellationToken);
        }

        public async Task<IRating?> GetRatingAsync(string id, CancellationToken cancellationToken)
        {
            try
            {
                return await Context.LoadAsync<DynamoDbRating>(DynamoDbRating.HashKey, id, cancellationToken);
            } 
            catch (AmazonDynamoDBException)
            {
                return null;
            }
            // throw if different error
        }

        public async Task<List<IRating>> GetRatingsAsync(CancellationToken cancellationToken)
        {
            var search = Context.QueryAsync<DynamoDbRating>(DynamoDbRating.HashKey);
            var results = await search.GetRemainingAsync(cancellationToken);
            return results.Cast<IRating>().ToList();
        }
    }
}
