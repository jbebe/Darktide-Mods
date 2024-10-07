using Amazon.DynamoDBv2.DataModel;
using Api.Services.Models;

namespace Api.Database.Models
{
    internal abstract record BaseEntity : IEntity
    {
        public abstract string EntityType { get; set; }

        public abstract string Id { get; set; }

        public required DateTime Created { get; set; }

        public DateTime? Updated { get; set; }

        [DynamoDBVersion]
        public int? Version { get; set; }

        public BaseEntity(string entityType) => EntityType = entityType;
    }
}
