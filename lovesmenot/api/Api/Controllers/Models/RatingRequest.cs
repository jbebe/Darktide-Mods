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
        /// Rating updates
        /// </summary>
        /// <remarks>
        /// KEY: Platform + Platform Id hash of the rated player
        /// </remarks>
        public Dictionary<string, TargetRequest>? Updates { get; set; }

        /// <summary>
        /// Deletable ratings
        /// </summary>
        /// <remarks>
        /// KEY: Platform + Platform Id hash of the rated player
        /// </remarks>
        public HashSet<string>? Deletes { get; set; }

        /// <summary>
        /// Hash of player's friend
        /// </summary>
        public required string[] Friends { get; set; }
    }
}
