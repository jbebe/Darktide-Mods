
namespace Api.Services.Models
{
    public record Rater
    {
        public required RatingType Type { get; set; }

        public required string AccountHash { get; set; }

        public required int MaxCharacterXp { get; set; }
    }
}