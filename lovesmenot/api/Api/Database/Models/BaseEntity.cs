using Amazon.DynamoDBv2.DataModel;

namespace Api.Database.Models
{
    internal abstract record BaseEntity : IBaseEntity
    {
        public static string HashKey => throw new NotImplementedException();

        [DynamoDBHashKey]
        public string EntityType => HashKey;

        [DynamoDBRangeKey]
        public required string Id { get; init; }

        public required DateTime Created { get; init; }

        public DateTime? Updated { get; set; }

        [DynamoDBVersion]
        public int? Version { get; }
    }
}
