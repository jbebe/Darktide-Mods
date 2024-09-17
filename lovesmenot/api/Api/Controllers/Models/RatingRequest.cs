namespace Api.Controllers.Models
{
    public class RatingRequest
    {
        /// <summary>
        /// Type of rating (negative / positive)
        /// </summary>
        public required RatingType Type { get; set; }

        /// <summary>
        /// Account GUID hash (for privacy/gdpr reasons) of the rated player
        /// </summary>
        public required string TargetHash { get; set; }

        /// <summary>
        /// Experience points of the rated character
        /// </summary>
        public int TargetXp { get; set; }

        /// <summary>
        /// Account GUID hash (for privacy/gdpr reasons) of the rating player
        /// </summary>
        public required string SourceHash { get; set; }

        /// <summary>
        /// Experience points of the rating character
        /// </summary>
        public int SourceXp { get; set; }

        /// <summary>
        /// Region where the rated player played
        /// </summary>
        public required string Region { get; set; }
    }
}
