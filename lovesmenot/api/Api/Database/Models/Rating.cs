using Amazon.DynamoDBv2.DataModel;
using Api.Services;
using Api.Services.Models;

namespace Api.Database.Models
{
    [DynamoDBTable("lovesmenot")]
    internal record DynamoDbRating : BaseEntity, IRating
    {
        [DynamoDBIgnore]
        public const string HashKey = "rating";

        /// <inheritdoc />
        [DynamoDBHashKey]
        public override required string EntityType { get; set; }

        /// <inheritdoc />
        [DynamoDBRangeKey]
        public override required string Id { get; set; }

        /// <inheritdoc />
        public required Dictionary<string, Rater> Ratings { get; set; }

        public DynamoDbRating() : base(HashKey) { }
    }
}
