using Api.Controllers.Models;
using Api.Database;
using Api.Services.Models;

namespace Api.Services
{
    public class RatingsService
    {
        private IDatabaseService Db { get; }

        public RatingsService(IDatabaseService db)
        {
            Db = db;
        }

        public async Task<Dictionary<string, RatingType>> GetRatingsAsync(CancellationToken cancellationToken)
        {
            var response = new Dictionary<string, RatingType>();
            foreach (var rating in await Db.GetRatingsAsync(cancellationToken))
            {
                var ratingType = Utils.CalculateRating(rating);
                if (ratingType != null)
                {
                    response[rating.Id] = ratingType.Value;
                }
            }

            return response;
        }

        public async Task UpdateRatingAsync(RatingRequest request, CancellationToken cancellationToken)
        {
            var raterId = request.SourceHash;
            foreach (var kvp in request.Targets)
            {
                var targetId = kvp.Key;
                var target = kvp.Value;
                var newRater = new Rater
                {
                    Type = target.Type,
                    MaxCharacterLevel = request.SourceLevel,
                    Reef = request.SourceReef,
                };

                var rating = await Db.GetRatingAsync(targetId, cancellationToken);
                if (rating == null)
                {
                    
                    rating = Db.CreateEntity(
                        targetId,
                        new Dictionary<string, Rater> { [raterId] = newRater },
                        new Metadata
                        {
                            MaxCharacterLevel = target.TargetLevel,
                        }
                    );
                }
                else
                {
                    rating.Updated = DateTime.UtcNow;

                    // Rater's info
                    if (rating.RatedBy.TryGetValue(raterId, out var rater))
                    {
                        rater.MaxCharacterLevel = Math.Max(rater.MaxCharacterLevel, request.SourceLevel);
                        rater.Type = target.Type;
                    }
                    else
                    {
                        rating.RatedBy[request.SourceHash] = newRater;
                    }
                    
                    // Metadata
                    rating.Metadata.MaxCharacterLevel = Math.Max(rating.Metadata.MaxCharacterLevel, target.TargetLevel);
                }
                await Db.CreateOrUpdateAsync(rating, cancellationToken);
            }
        }
    }
}
