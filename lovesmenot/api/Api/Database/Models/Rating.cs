using Amazon.DynamoDBv2.DataModel;
using Api.Services;
using Api.Services.Models;

namespace Api.Database.Models
{
    [DynamoDBTable("lovesmenot")]
    public record DynamoDbRating : BaseEntity, IRating, IBaseEntity
    {
        static string IBaseEntity.HashKey => "rating";

        /// <inheritdoc />
        public required Dictionary<string, Rater> Ratings { get; init; }
    }
}
