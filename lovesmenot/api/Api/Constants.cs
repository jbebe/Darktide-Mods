using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace Api
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
        public const int UsableScore = UsableRaterCount * MaxLevel;

        public static class Auth
        {
            /// <summary>
            /// Own URL of the server
            /// </summary>
            public static string SelfUrl => Environment.GetEnvironmentVariable("LOVESMENOT_API_URL")!;

            /// <summary>
            /// Api key for querying steam user data (<see href="https://steamcommunity.com/dev/apikey"/>)
            /// </summary>
            public static string SteamWebApiKey => Environment.GetEnvironmentVariable("STEAM_WEB_API_KEY")!;

            /// <summary>
            /// Jwt key that signs tokens
            /// </summary>
            private static string JwtKey => Environment.GetEnvironmentVariable("LOVESMENOT_JWT_KEY")!;

            public static SymmetricSecurityKey JwtKeyObject => new(Encoding.UTF8.GetBytes(JwtKey));

            /// <summary>
            /// Issuer of generated jwt tokens
            /// </summary>
            public const string JwtIssuer = "lovesmenot";

            /// <summary>
            /// Issuer of generated jwt tokens
            /// </summary>
            public const string PlatformId = "pid";

            /// <summary>
            /// The static website (for auth flow)
            /// </summary>
            public static string WebsiteUrl => Environment.GetEnvironmentVariable("LOVESMENOT_WEBSITE_URL")!;

            public static string WebsiteUrlTyped(AuthenticationType type) => $"{WebsiteUrl}?type={type.ToString().ToLower()}";

            /// <summary>
            /// Mandatory parameter for Xbox Live auth flow
            /// </summary>
            public static string XboxClientId => Environment.GetEnvironmentVariable("AZURE_APP_CLIENT_ID")!;

            /// <summary>
            /// Secret for validating auth client legibility
            /// </summary>
            public static string XboxSecret => Environment.GetEnvironmentVariable("AZURE_APP_SECRET")!;
        }
    }
}
