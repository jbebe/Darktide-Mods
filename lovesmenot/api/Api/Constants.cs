using Microsoft.IdentityModel.Tokens;
using System.Security.Cryptography;
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
            static Auth()
            {
                var privateKeyRaw = Convert.FromBase64String(JwtKey);
                var privateRsa = new RSACryptoServiceProvider();
                privateRsa.ImportRSAPrivateKey(new ReadOnlySpan<byte>(privateKeyRaw), out _);
                JwtSignerKey = new RsaSecurityKey(privateRsa);

                var publicKeyRaw = Convert.FromBase64String(JwtPublicKey);
                var publicRsa = new RSACryptoServiceProvider();
                publicRsa.ImportRSAPublicKey(new ReadOnlySpan<byte>(publicKeyRaw), out _);
                JwtValidateKey = new RsaSecurityKey(publicRsa);
            }

            /// <summary>
            /// Steam Dartkide id
            /// </summary>
            public const int SteamDarktideId = 1361210;

            /// <summary>
            /// Xbox Dartkide id (game title)
            /// </summary>
            public const int XboxDarktideId = 1684508835;

            /// <summary>
            /// Own URL of the server
            /// </summary>
            public static string SelfUrl => Environment.GetEnvironmentVariable("LOVESMENOT_API_URL")!;

            /// <summary>
            /// Api key for querying steam user data (<see href="https://steamcommunity.com/dev/apikey"/>)
            /// </summary>
            public static string SteamWebApiKey => Environment.GetEnvironmentVariable("STEAM_WEB_API_KEY")!;

            /// <summary>
            /// Raw 2048 bit RSA256 key that signs tokens
            /// </summary>
            private static string JwtKey => Environment.GetEnvironmentVariable("LOVESMENOT_JWT_KEY")!;

            /// <summary>
            /// Raw public key that verifies tokens
            /// </summary>
            private static string JwtPublicKey => Environment.GetEnvironmentVariable("LOVESMENOT_JWT_PUBLIC_KEY")!;

            /// <summary>
            /// Key that signs new JWT tokens
            /// </summary>
            public static RsaSecurityKey JwtSignerKey;

            /// <summary>
            /// Key that validates JWT tokens
            /// </summary>
            public static RsaSecurityKey JwtValidateKey;

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

            public static string WebsiteUrlWithTyped(AuthenticationType type) => $"{WebsiteUrl}?type={type.ToString().ToLower()}";

            public static string WebsiteUrlWithError(PublicError code) => $"{WebsiteUrl}?error={code}";

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
