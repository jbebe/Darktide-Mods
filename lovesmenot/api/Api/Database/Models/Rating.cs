using Amazon.DynamoDBv2.DataModel;
using Api.Services.Models;

namespace Api.Database.Models
{
    [DynamoDBTable("lovesmenot")]
    public record DynamoDbRating : IRating
    {
        [DynamoDBIgnore]
        public const string HashKey = "rating";

        [DynamoDBHashKey]
        public string EntityType { get; set; } = HashKey;

        [DynamoDBRangeKey]
        public required string Id { get; init; }

        public required Dictionary<string, Rater> RatedBy { get; init; }

        public required Metadata Metadata { get; init; }

        public required DateTime Created { get; init; }

        public DateTime? Updated { get; set; }

        [DynamoDBVersion]
        public int? Version { get; }
    }
}
