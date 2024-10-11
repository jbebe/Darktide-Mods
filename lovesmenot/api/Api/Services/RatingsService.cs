using Api.Controllers.Models;
using Api.Database;
using System.Security.Authentication;

namespace Api.Services
{
    public class RatingsService
    {
        private IDatabaseService Db { get; }

        private IHttpContextAccessor HttpContextAccessor { get; }

        private HttpContext HttpContext => HttpContextAccessor.HttpContext!;

        public RatingsService(IDatabaseService db, IHttpContextAccessor httpContextAccessor)
        {
            Db = db;
            HttpContextAccessor = httpContextAccessor;
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

        public async Task UpdateAsync(RatingRequest request, CancellationToken cancellationToken)
        {
            var raterId = HttpContext.User.Claims.FirstOrDefault(x => x.Type == Constants.Auth.PlatformId)?.Value
                ?? throw new AuthException(InternalError.CallerIdMissing);

            var now = DateTime.UtcNow;
            await UpdateAccountAsync(raterId, request.CharacterLevel, request.Reef, request.Friends, now, cancellationToken);

            if (request.Accounts.Any(x => x.Key == raterId))
                throw new ModException(InternalError.SelfRating);

            foreach (var kvp in request.Accounts)
            {
                var ratedId = kvp.Key;
                var ratedInfo = kvp.Value;

                await UpdateAccountAsync(ratedId, ratedInfo.CharacterLevel, request.Reef, [], now, cancellationToken);
                await UpdateRatingAsync(ratedId, raterId, request.CharacterLevel, ratedInfo.Type, now, cancellationToken);
            }
        }

        private async Task UpdateAccountAsync(
            string id, int characterLevel, string reef, string[] friends, DateTime timestamp, CancellationToken cancellationToken)
        {
            var account = await Db.GetAccountAsync(id, cancellationToken);
            if (account == null)
            {
                account = Db.CreateAccount(id, characterLevel, reef, friends, timestamp);
            }
            else
            {
                account.CharacterLevel = Math.Max(characterLevel, account.CharacterLevel);
                account.Reefs.Add(reef);
                foreach (var friend in friends) account.Friends.Add(friend);
                account.Updated = timestamp;
            }
            await Db.CreateOrUpdateAccountAsync(account, cancellationToken);
        }

        private async Task UpdateRatingAsync(
            string ratedId, string raterId, int raterLevel, RatingType ratingType, DateTime timestamp, CancellationToken cancellationToken)
        {
            var rating = await Db.GetRatingAsync(ratedId, cancellationToken);
            var newRater = new Rater
            {
                Rating = ratingType,
                CharacterLevel = raterLevel,
                Update = timestamp,
            };
            if (rating == null)
            {
                rating = Db.CreateRating(
                    ratedId, 
                    new Dictionary<string, Rater>{ [raterId] = newRater },
                    timestamp
                );
            }
            else
            {
                if (rating.Ratings.TryGetValue(raterId, out var rater))
                {
                    if (rater.Rating == ratingType && rater.CharacterLevel == raterLevel)
                    {
                        // Nothing to update
                        return;
                    }
                    rater.Rating = ratingType;
                    rater.CharacterLevel = raterLevel;
                    rater.Update = timestamp;
                }
                else
                {
                    rating.Ratings[raterId] = newRater;
                }
                rating.Updated = DateTime.UtcNow;
            }
            await Db.CreateOrUpdateRatingAsync(rating, cancellationToken);
        }
    }
}
