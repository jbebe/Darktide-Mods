using Api.Controllers.Models;
using Api.Services.Models;
using System.Runtime.CompilerServices;

namespace Api.Services
{
    public class RatingsService
    {
        private IDatabaseService Db { get; }

        public RatingsService(IDatabaseService db)
        {
            Db = db;
        }

        public async IAsyncEnumerable<(Rating? Positive, Rating? Negative)> GetRatingsAsync([EnumeratorCancellation] CancellationToken cancellationToken)
        {
            await foreach (var rating in Db.GetRatingsAsync(cancellationToken))
            {
                var score = rating.Score;
                if (Math.Abs(score) >= Constants.UsableScore)
                {
                    if (score < 0)
                    {
                        yield return (null, rating);
                    }
                    else
                    {
                        yield return (rating, null);
                    }
                }
            }
        }

        public async Task AddRatingAsync(RatingRequest request, CancellationToken cancellationToken)
        {
            var targetId = request.TargetHash;
            var rating = await Db.GetRatingAsync(targetId, cancellationToken);
            var now = DateTime.UtcNow;
            var newRater = new Rater
            {
                AccountHash = request.SourceHash,
                Type = request.Type,
                Xp = request.SourceXp,
            };

            if (rating == null)
            {
                rating = new Rating
                {
                    Id = targetId,
                    Created = now,
                    Updated = null,
                    RatedBy = [newRater],
                    Metadata = new Metadata
                    {
                        Regions = request.Region != null ? [request.Region] : [],
                        MaxCharacterXp = request.TargetXp,
                    },
                };
            }
            else
            {
                rating.Updated = now;

                // Rater's info
                var rater = rating.RatedBy.SingleOrDefault(x => x.AccountHash == request.SourceHash);
                if (rater == null)
                {
                    rating.RatedBy.Add(newRater);
                }
                else
                {
                    rater.Xp = Math.Max(rater.Xp, request.SourceXp);
                    rater.Type = request.Type;
                }

                // Metadata
                rating.Metadata.MaxCharacterXp = Math.Max(rating.Metadata.MaxCharacterXp, request.TargetXp);
                rating.Metadata.Regions.Add(request.Region);
            }

            await Db.CreateOrUpdateAsync(rating, cancellationToken);
        }
    }
}
