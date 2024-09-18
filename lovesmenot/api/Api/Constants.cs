using Microsoft.AspNetCore.Routing;

namespace Api
{
    public static class Constants
    {
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

        /// <summary>
        /// cloud provider regions where players can play
        /// </summary>
        /// <remarks>
        /// AWS doesn't prefix their regions with 'aws' but Fatshark does
        /// leaving it open for other cloud providers if needed, so we keep the prefix too
        /// so that eu-central-1 won't collide with Azure in the future, for example
        /// </remarks>
        public readonly static HashSet<string> DarktideRegions = [
            "aws-af-south-1",
            "aws-ap-east-1",
            "aws-ap-northeast-1",
            "aws-ap-northeast-2",
            "aws-ap-south-1",
            "aws-ap-southeast-1",
            "aws-ap-southeast-2",
            "aws-ca-central-1",
            "aws-eu-central-1",
            "aws-eu-north-1",
            "aws-eu-west-1",
            "aws-eu-west-2",
            "aws-me-south-1",
            "aws-sa-east-1",
            "aws-us-east-1",
            "aws-us-east-2",
            "aws-us-west-1",
            "aws-us-west-2",
        ];
    }
}
