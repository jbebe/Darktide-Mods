using System.Text.Json.Serialization;

namespace Api.Controllers.Models
{
    public record TargetRequest
    {
        /// <summary>
        /// Type of rating (negative / positive)
        /// </summary>
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public required RatingType Type { get; set; }

        /// <summary>
        /// Account GUID hash (for privacy/gdpr reasons) of the rated player
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
        /// Account GUID hash (for privacy/gdpr reasons) of the rating player
        /// </summary>
        public required string SourceHash { get; set; }

        /// <summary>
        /// Experience points of the rating character
        /// </summary>
        public int SourceXp { get; set; }
    }
}
