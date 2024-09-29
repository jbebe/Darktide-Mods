using System.ComponentModel.DataAnnotations;

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
        public int TargetLevel { get; set; }
    }

    public record RatingRequest
    {
        /// <summary>
        /// Account GUID hash of the rating player
        /// </summary>
        public required string SourceHash { get; set; }

        /// <summary>
        /// Experience points of the rating character
        /// </summary>
        public int SourceLevel { get; set; }

        /// <summary>
        /// Superset of cloud provider region.
        /// </summary>
        /// <example>eu</example>
        public required string SourceReef { get; set; }
        
        /// <summary>
        /// KEY: Account GUID hash of the rated player
        /// </summary>
        public required Dictionary<string, TargetRequest> Targets { get; set; }
    }
}
