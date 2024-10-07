using Amazon.DynamoDBv2.DataModel;
using Api.Services.Models;

namespace Api.Database.Models
{
    [DynamoDBTable("lovesmenot")]
    internal record DynamoDbAccount : BaseEntity, IAccount
    {
        [DynamoDBIgnore]
        public const string HashKey = "account";

        /// <inheritdoc />
        [DynamoDBHashKey]
        public override required string EntityType { get; set; }

        /// <inheritdoc />
        [DynamoDBRangeKey]
        public override required string Id { get; set; }

        /// <inheritdoc />
        public required int CharacterLevel { get; set; }

        /// <inheritdoc />
        public required HashSet<string> Reefs { get; set; }

        /// <inheritdoc />
        public required HashSet<string> Friends { get; set; }

        public DynamoDbAccount() : base(HashKey) { }
    }
}
