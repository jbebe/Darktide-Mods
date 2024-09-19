using Microsoft.AspNetCore.Routing;

namespace Api
{
    public static class Constants
    {
        public const int ApiVersion = 1;

        /// <summary>
        /// Level 20 xp according to Darktide
        /// </summary>
        public const int BeginnerXp = 57255;

        /// <summary>
        /// Max level xp according to Darktide
        /// </summary>
        public const int MaxLevelXp = 143405;

        /// <summary>
        /// A decent experience point is earned if you are (true) level 200
        /// </summary>
        public const int DecentXp = MaxLevelXp + (11100 * 200);

        /// <summary>
        /// Minimum amount of raters that makes a score usable
        /// </summary>
        public const int UsableRaterCount = 4;

        /// <summary>
        /// A score is usable if its absolute value is bigger than 4 max level player xp
        /// </summary>
        public const int UsableScore = UsableRaterCount * MaxLevelXp;
    }
}
