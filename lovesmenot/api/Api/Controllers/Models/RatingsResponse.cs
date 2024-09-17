namespace Api.Controllers.Models
{
    public record RatingResponse
    {
        public required RatingType Type { get; set; }

        public required string Hash { get; set; }
    }
}
