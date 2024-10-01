﻿namespace Api
{
    public static class Constants
    {
        public const int ApiVersion = 1;

        /// <summary>
        /// First level according to Darktide
        /// </summary>
        public const int MinLevel = 1;

        /// <summary>
        /// Max level according to Darktide
        /// </summary>
        public const int MaxLevel = 30;

        /// <summary>
        /// Minimum amount of raters that makes a score usable
        /// </summary>
        public const int UsableRaterCount = 4;

        /// <summary>
        /// A score is usable if its absolute value is bigger than n times the max level (n max level player)
        /// </summary>
        public const int UsableScore = 0; // TEST ONLY

        /// <summary>
        /// Issuer of generated jwt tokens
        /// </summary>
        public const string JwtIssuer = "lovesmenot";

        public static class Secrets
        {
            /// <summary>
            /// Api key for querying steam user data (<see href="https://steamcommunity.com/dev/apikey"/>)
            /// </summary>
            public static string SteamWebApiKey => Environment.GetEnvironmentVariable("STEAM_WEB_API_KEY")!;

            /// <summary>
            /// Jwt key that signs tokens
            /// </summary>
            public static string JwtKey => Environment.GetEnvironmentVariable("LOVESMENOT_JWT_KEY")!;
        }
    }
}
