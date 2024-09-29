
namespace Api.Services.Models
{
    public record Rater
    {
        public required RatingType Type { get; set; }

        public required int MaxCharacterLevel { get; set; }

        public required string Reef { get; set; }
    }
}