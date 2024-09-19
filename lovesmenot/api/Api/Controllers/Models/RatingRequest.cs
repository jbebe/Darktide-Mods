﻿  namespace Api.Controllers.Models
{
    public record TargetRequest
    {
        /// <summary>
        /// Type of rating (negative / positive)
        /// </summary>
        public required RatingType Type { get; set; }

        /// <summary>
        /// Account GUID hash of the rated player
        /// </summary>
        public required string TargetHash { get; set; }

        /// <summary>
        /// Experience points of the rated character
        /// </summary>
        public int TargetXp { get; set; }
    }

    public record RatingRequest
    {
        public required TargetRequest[] Targets { get; set; }

        /// <summary>
        /// Account GUID hash of the rating player
        /// </summary>
        public required string SourceHash { get; set; }

        /// <summary>
        /// Experience points of the rating character
        /// </summary>
        public int SourceXp { get; set; }

        /// <summary>
        /// Superset of cloud provider region.
        /// </summary>
        /// <example>eu</example>
        public required string SourceReef { get; set; }
    }
}
