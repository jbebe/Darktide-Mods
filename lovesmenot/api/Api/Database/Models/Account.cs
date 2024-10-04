using Amazon.DynamoDBv2.DataModel;
using Api.Services.Models;

namespace Api.Database.Models
{
    [DynamoDBTable("lovesmenot")]
    internal record DynamoDbAccount : BaseEntity, IAccount, IBaseEntity
    {
        static string IBaseEntity.HashKey => "account";

        /// <inheritdoc />
        public required int CharacterLevel { get; set; }

        /// <inheritdoc />
        public required HashSet<string> Reefs { get; set; }

        /// <inheritdoc />
        public required HashSet<string> Friends { get; set; }
    }
}
