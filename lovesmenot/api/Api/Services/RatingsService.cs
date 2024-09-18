using Api.Controllers.Models;
using Api.Database;
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

        public async IAsyncEnumerable<RatingResponse> GetRatingsAsync(string region, [EnumeratorCancellation] CancellationToken cancellationToken)
        {
            foreach (var rating in await Db.GetRatingsAsync(region, cancellationToken))
            {
                var ratingType = Utils.CalculateRating(rating);
                if (ratingType != null)
                {
                    yield return new RatingResponse
                    {
                        Hash = rating.Id,
                        Type = ratingType.Value,
                    };
                }
            }
        }

        public async Task UpdateRatingAsync(string region, RatingRequest request, CancellationToken cancellationToken)
        {
            foreach (var target in request.Targets)
            {
                var targetId = target.TargetHash;
                var newRater = new Rater
                {
                    AccountHash = request.SourceHash,
                    Type = target.Type,
                    MaxCharacterXp = request.SourceXp,
                };

                var rating = await Db.GetRatingAsync(region, targetId, cancellationToken);
                if (rating == null)
                {
                    rating = Db.CreateEntity(
                        region,
                        targetId,
                        [newRater],
                        new Metadata
                        {
                            MaxCharacterXp = target.TargetXp,
                        }
                    );
                }
                else
                {
                    rating.Updated = DateTime.UtcNow;

                    // Rater's info
                    var rater = rating.RatedBy.SingleOrDefault(x => x.AccountHash == request.SourceHash);
                    if (rater == null)
                    {
                        rating.RatedBy.Add(newRater);
                    }
                    else
                    {
                        rater.MaxCharacterXp = Math.Max(rater.MaxCharacterXp, request.SourceXp);
                        rater.Type = target.Type;
                    }

                    // Metadata
                    rating.Metadata.MaxCharacterXp = Math.Max(rating.Metadata.MaxCharacterXp, target.TargetXp);
                }
                await Db.CreateOrUpdateAsync(rating, cancellationToken);
            }
        }
    }
}
