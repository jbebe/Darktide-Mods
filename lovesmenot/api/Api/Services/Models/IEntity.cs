namespace Api.Services.Models
{
    public interface IEntity
    {
        /// <summary>
        /// Type of the entity
        /// </summary>
        string EntityType { get; }

        /// <summary>
        /// Id of the entity
        /// </summary>
        string Id { get; }

        /// <summary>
        /// Date when entity was created
        /// </summary>
        DateTime Created { get; }

        /// <summary>
        /// Last entity modification date
        /// </summary>
        DateTime? Updated { get; set; }
    }
}
