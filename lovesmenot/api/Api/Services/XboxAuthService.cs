using Microsoft.AspNetCore.WebUtilities;
using System.Net.Http.Headers;
using System.Text.Encodings.Web;
using System.Text.Json;

namespace Api.Services
{
    public class XboxAuthService : AuthServiceBase
    {
        private IHttpClientFactory HttpFactory { get; }

        private static string RedirectUrl => $"{Constants.Auth.SelfUrl}/callback/xbox";

        private const string Scope = "xboxlive.signin offline_access openid email";

        private const string CodeForAccessTokenUrl = "https://login.live.com/oauth20_token.srf";

        private JsonSerializerOptions JsonOptions { get; }

        public XboxAuthService(IHttpContextAccessor httpContextAccessor, IHttpClientFactory factory) : base(httpContextAccessor)
        {
            HttpFactory = factory;
            JsonOptions = new JsonSerializerOptions
            {
                Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
            };
        }

        public void Challenge()
        {
            var query = new Dictionary<string, string?>
            {
                ["client_id"] = Constants.Auth.XboxClientId,
                ["redirect_uri"] = RedirectUrl,
                ["response_type"] = "code",
                ["scope"] = Scope,
            };
            var authUrl = QueryHelpers.AddQueryString("https://login.live.com/oauth20_authorize.srf", query);
            HttpContext.Response.Redirect(authUrl, permanent: false);
        }

        public async Task HandleCallbackAsync(string? code, string? error, CancellationToken cancellationToken)
        {
            if (code == null)
            {
                if (error == "access_denied")
                    throw new AuthException(InternalError.AuthCancelled);
                throw new AuthException(InternalError.XboxLoginError);
            }

            // Create token to access xbox api
            (UserTokenResponseClaimsItem Claims, UserTokenResponse TokenResponse) authResult;
            try
            {
                authResult = await ExchangeCodeForAccessTokenAsync(code, cancellationToken);
            }
            catch (Exception ex)
            {
                throw new AuthException(InternalError.XboxTokenExchangeError, exception: ex);
            }

            // Check if user owns Darktide
            await CheckForDarktideAsync(authResult.Claims, authResult.TokenResponse.Token, cancellationToken);

            // Create token
            // No need to lower xuid for normalization as it's numeric
            RedirectToWebsiteWithAccessToken(AuthenticationType.Xbox, authResult.Claims.xid!);
        }

        private async Task CheckForDarktideAsync(UserTokenResponseClaimsItem item, string token, CancellationToken cancellationToken)
        {
            var client = HttpFactory.CreateClient();
            client.DefaultRequestHeaders.Add("X-Xbl-Contract-Version", "2");
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("XBL3.0", $"x={item.uhs};{token}");

            // Check if user has any achivements for Darktide
            // Why don't we just query all owned games of the user?
            // https://github.com/microsoft/xbox-live-api/issues/559
            // > Is there any way to retrieve xbox live account games?
            // > Not as far as I know
            // Why don't we just query activities for Darktide?
            // Because it returns "Missing title Id claim.",
            // meaning we need to be authorized as a game publisher to access the api.
            var response = await client.GetAsync(
                    $"https://achievements.xboxlive.com/users/xuid({item.xid})/history/titles?maxItems=1&titleId={Constants.Auth.XboxDarktideId}",
                    cancellationToken);
            if (!response.IsSuccessStatusCode)
                throw new AuthException(InternalError.XboxGetAchivementsError, response.StatusCode);
            var achivements = (await response.Content.ReadFromJsonAsync<AchivementsResponse>(cancellationToken))!;

            if (achivements.titles.Length == 0)
                throw new AuthException(InternalError.XboxNoOwnership);
        }

#pragma warning disable IDE1006

        class AchivementsResponse
        {
            // The actual content of the response is not important for us
            public required object[] titles { get; set; }
        }

        record CodeForAccessTokenRequest(
            string code,
            string client_id,
            string grant_type,
            string redirect_uri,
            string scope,
            string client_secret
        );

        record LiveAuthResponse(
            string token_type,
            long expires_in,
            string scope,
            string access_token,
            string? refresh_token,
            string user_id
        );

        record UserTokenRequestProperties(
            string AuthMethod,
            string SiteName,
            string RpsTicket
        );

        record UserTokenRequest(
            string RelyingParty,
            string TokenType,
            UserTokenRequestProperties Properties
        );

        record UserTokenResponseClaimsItem(
            // Xbox account name
            string? gtg,
            // XUID
            string? xid,
            // User Id hash,
            string uhs,
            // Adult/Child/?
            string? agg,
            // byte byte
            string? usr,
            // byte
            string? utr,
            // byte[31]
            string? prv
        );

        record UserTokenResponseClaims(UserTokenResponseClaimsItem[] xui);

        record UserTokenResponse(
            string IssueInstant,
            string NotAfter,
            string Token,
            UserTokenResponseClaims DisplayClaims
        );

        record XstsTokenRequestProperties(
            string[]? UserTokens,
            string SandboxId
        );

        record XstsTokenRequest(
            string RelyingParty,
            string TokenType,
            XstsTokenRequestProperties Properties
        );

#pragma warning restore IDE1006

        private async Task<(UserTokenResponseClaimsItem Claims, UserTokenResponse stsTokenResponse)>
            ExchangeCodeForAccessTokenAsync(string code, CancellationToken cancellationToken)
        {
            var client = HttpFactory.CreateClient();
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            //
            // code --> rps ticket
            //

            LiveAuthResponse liveAuthResponse;
            {
                var request = new CodeForAccessTokenRequest(
                    code,
                    Constants.Auth.XboxClientId,
                    "authorization_code",
                    RedirectUrl,
                    Scope,
                    Constants.Auth.XboxSecret
                );
                var requestJson = JsonSerializer.Serialize(request);
                var requestDict = JsonSerializer.Deserialize<Dictionary<string, string>>(requestJson)!;
                using var content = new FormUrlEncodedContent(requestDict);
                content.Headers.Clear();
                content.Headers.ContentType = new MediaTypeHeaderValue("application/x-www-form-urlencoded");
                var response = await client.PostAsync(CodeForAccessTokenUrl, content);
                response.EnsureSuccessStatusCode();
                liveAuthResponse = (await response.Content.ReadFromJsonAsync<LiveAuthResponse>(cancellationToken))!;
            }

            //
            // rps ticket --> user token
            //
            UserTokenResponse userTokenResponse;
            {
                const string customAzureApplication = "d";
                var rpsTicket = $"{customAzureApplication}={liveAuthResponse.access_token}";
                var request = new UserTokenRequest(
                    "http://auth.xboxlive.com",
                    "JWT",
                    new UserTokenRequestProperties(
                        "RPS",
                        "user.auth.xboxlive.com",
                        rpsTicket
                    )
                );
                Console.WriteLine(JsonSerializer.Serialize(request));
                client.DefaultRequestHeaders.Add("X-Xbl-Contract-Version", "2");
                var response = await client.PostAsJsonAsync(
                    "https://user.auth.xboxlive.com/user/authenticate", request, JsonOptions, cancellationToken);
                response.EnsureSuccessStatusCode();
                userTokenResponse = (await response.Content.ReadFromJsonAsync<UserTokenResponse>(cancellationToken))!;
            }

            //
            // user token --> (x)sts token
            //
            UserTokenResponse stsTokenResponse;
            const string relyingParty = "http://xboxlive.com"; // or http://licensing.xboxlive.com
            {
                var request = new XstsTokenRequest(
                    RelyingParty: relyingParty,
                    TokenType: "JWT",
                    Properties: new XstsTokenRequestProperties(
                        UserTokens: [userTokenResponse.Token],
                        SandboxId: "RETAIL"
                    )
                );
                var response = await client.PostAsJsonAsync(
                    "https://xsts.auth.xboxlive.com/xsts/authorize", request, JsonOptions, cancellationToken);
                response.EnsureSuccessStatusCode();
                stsTokenResponse = (await response.Content.ReadFromJsonAsync<UserTokenResponse>(cancellationToken))!;
            }

            return (stsTokenResponse.DisplayClaims.xui[0], stsTokenResponse);
        }
    }
}
