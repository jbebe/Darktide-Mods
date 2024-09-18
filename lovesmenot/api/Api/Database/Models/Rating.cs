using Amazon.DynamoDBv2.DataModel;
using Api.Services.Models;

namespace Api.Database.Models
{
    [DynamoDBTable("lovesmenot")]
    public record DynamoDbRating : IRating
    {
        [DynamoDBHashKey]
        public required string Region { get; init; }

        [DynamoDBRangeKey]
        public required string Id { get; init; }

        public required List<Rater> RatedBy { get; init; }

        public required Metadata Metadata { get; init; }

        public required DateTime Created { get; init; }

        public DateTime? Updated { get; set; }

        [DynamoDBVersion]
        public int? Version { get; }
    }
}
