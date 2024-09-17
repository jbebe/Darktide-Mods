using Api.Services.Models;

namespace Api
{
    public static class Utils
    {
        public static double CalculateScore(Rater rater)
        {
            var sign = (rater.Type == RatingType.Positive ? 1.0 : -1.0);
            var modifier = rater.Xp switch
            {
                var xp when xp >= Constants.DecentXp => 2,
                var xp when xp >= Constants.MaxLevelXp => 1,
                var xp when xp >= Constants.BeginnerXp => 0.5,
                _ => 0.25,
            };
            return modifier * (sign * rater.Xp);
        }

        public static RatingType? CalculateRating(Rating rating)
        {
            var score = rating.Score;
            if (Math.Abs(score) >= Constants.UsableScore && rating.RatedBy.Count >= Constants.UsableRaterCount)
                return score < 0 ? RatingType.Negative : RatingType.Positive;

            return null;
        }
    }
}
