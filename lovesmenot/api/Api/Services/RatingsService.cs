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

        public async IAsyncEnumerable<RatingResponse> GetRatingsAsync([EnumeratorCancellation] CancellationToken cancellationToken)
        {
            foreach (var rating in await Db.GetRatingsAsync(cancellationToken))
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

        public async Task UpdateRatingAsync(RatingRequest request, CancellationToken cancellationToken)
        {
            foreach (var target in request.Targets)
            {
                var targetId = target.TargetHash;
                var newRater = new Rater
                {
                    Id = request.SourceHash,
                    Type = target.Type,
                    MaxCharacterXp = request.SourceXp,
                    Reef = request.SourceReef,
                };

                var rating = await Db.GetRatingAsync(targetId, cancellationToken);
                if (rating == null)
                {
                    rating = Db.CreateEntity(
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
                    var rater = rating.RatedBy.SingleOrDefault(x => x.Id == request.SourceHash);
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
