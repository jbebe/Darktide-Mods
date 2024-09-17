namespace Api.Services.Models
{
    public record Rater
    {
        public required RatingType Type { get; set; }

        public required string AccountHash { get; set; }

        public required int Xp { get; set; }
    }

    public record Rating
    {
        public required string Id { get; set; }

        public required List<Rater> RatedBy { get; set; } = [];

        public required Metadata Metadata { get; set; }

        public required DateTime Created { get; set; }

        public DateTime? Updated { get; set; }

        public double Score => RatedBy.Sum(Utils.CalculateScore);
    }
}
