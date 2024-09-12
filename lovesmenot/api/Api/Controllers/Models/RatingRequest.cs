namespace Api.Controllers.Models
{
    public class RatingRequest
    {
        public required RatingType Type { get; set; }

        public required string Hash { get; set; }

        public required DateTime CreationDate { get; set; }

        public string? Region { get; set; }
    }
}
