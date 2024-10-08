namespace Api.Services.Models
{
    public interface IAccount : IEntity
    {
        /// <summary>
        /// The player's highest character level
        /// </summary>
        int CharacterLevel { get; set; }

        /// <summary>
        /// All continents where the player played
        /// </summary>
        HashSet<string> Reefs { get; set; }

        /// <summary>
        /// The player's friends's hashed ids
        /// </summary>
        HashSet<string> Friends { get; set; }
    }
}