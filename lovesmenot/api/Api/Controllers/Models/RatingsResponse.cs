namespace Api.Controllers.Models
{
    public class RatingResponse
    {
        public required RatingType Type { get; set; }

        public required string Hash { get; set; }
    }
}
