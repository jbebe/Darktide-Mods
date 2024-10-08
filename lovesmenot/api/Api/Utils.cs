﻿using Api.Services;
using Api.Services.Models;

namespace Api
{
    public static class Utils
    {
        public static double CalculateScore(Rater rater)
        {
            var sign = (rater.Rating == RatingType.Positive ? 1.0 : -1.0);
            var modifier = rater.CharacterLevel switch
            {
                // 30+ players
                var level when level == Constants.MaxLevel => 1,
                // <30, a.k.a. beginners
                _ => 0.25,
            };
            return modifier * sign * rater.CharacterLevel;
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
