namespace Api.Controllers.Models
{
    public record TargetRequest
    {
        /// <summary>
        /// Type of rating (negative / positive)
        /// </summary>
        public required RatingType Type { get; set; }

        /// <summary>
        /// Experience points of the rated character
        /// </summary>
        public required int CharacterLevel { get; set; }
    }

    public record RatingRequest
    {
        /// <summary>
        /// Experience points of the rating character
        /// </summary>
        public required int CharacterLevel { get; set; }

        /// <summary>
        /// Superset of cloud provider region.
        /// </summary>
        /// <example>eu</example>
        public required string Reef { get; set; }
        
        /// <summary>
        /// KEY: Account GUID hash of the rated player
        /// </summary>
        public required Dictionary<string, TargetRequest> Accounts { get; set; }

        /// <summary>
        /// Hash of player's friend's account id
        /// </summary>
        public required string[] Friends { get; set; }
    }
}
