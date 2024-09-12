namespace Api.Services.Models
{
    public class Rating
    {
        public required RatingType Type { get; set; }

        public required string Hash { get; set; }

        public required Metadata Metadata { get; set; }

        public required DateTime Created { get; set; }

        public DateTime? Updated { get; set; }
    }
}
