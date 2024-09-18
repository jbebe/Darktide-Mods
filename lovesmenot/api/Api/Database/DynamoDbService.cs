using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Api.Database.Models;
using Api.Services.Models;

namespace Api.Database
{
    public class DynamoDbService : IDatabaseService
    {
        public DynamoDBContext Context { get; }

        public DynamoDbService(DynamoDBContext context)
        {
            Context = context;
        }

        public IRating CreateEntity(string region, string id, List<Rater> ratedBy, Metadata metadata)
        {
            return new DynamoDbRating
            {
                Region = Utils.NormalizeDarktideRegion(region),
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

        public async Task<IRating?> GetRatingAsync(string region, string id, CancellationToken cancellationToken)
        {
            try
            {
                return await Context.LoadAsync<DynamoDbRating>(region, id, cancellationToken);
            } 
            catch (AmazonDynamoDBException)
            {
                return null;
            }
            // throw if different error
        }

        public async Task<List<IRating>> GetRatingsAsync(string region, CancellationToken cancellationToken)
        {
            var search = Context.QueryAsync<DynamoDbRating>(region);
            var results = await search.GetRemainingAsync(cancellationToken);
            return results.Cast<IRating>().ToList();
        }
    }
}
