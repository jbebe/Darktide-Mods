namespace Api.Services
{
    public record Rater
    {
        /// <summary>
        /// Rating of the player
        /// </summary>
        public required RatingType Rating { get; set; }

        /// <summary>
        /// Current character level of rating player
        /// </summary>
        /// <remarks>
        /// It is only a snapshot of the player's level for the moment they rated said player.
        /// It helps with weighting ratings when score is calculated.
        /// </remarks>
        public required int CharacterLevel { get; set; }

        /// <summary>
        /// Timestamp for the last time this rating has changed
        /// </summary>
        public DateTime Update { get; set; }
    }
}
