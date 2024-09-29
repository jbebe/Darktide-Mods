using Api.Services.Models;

namespace Api
{
    public static class Utils
    {
        public static double CalculateScore(Rater rater)
        {
            var sign = (rater.Type == RatingType.Positive ? 1.0 : -1.0);
            var modifier = rater.MaxCharacterLevel switch
            {
                // 30+ players
                var level when level == Constants.MaxLevel => 1,
                // <30, a.k.a. beginners
                _ => 0.25,
            };
            return modifier * sign * rater.MaxCharacterLevel;
        }

        public static RatingType? CalculateRating(IRating rating)
        {
            var score = rating.Score;
            if (Math.Abs(score) >= Constants.UsableScore)
                return score < 0 ? RatingType.Negative : RatingType.Positive;

            return null;
        }
    }
}
