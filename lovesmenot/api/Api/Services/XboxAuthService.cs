using Microsoft.AspNetCore.Http.Json;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;
using System.Net.Http.Headers;
using System.Text.Encodings.Web;
using System.Text.Json;
using static AspNet.Security.OpenId.OpenIdAuthenticationConstants;

namespace Api.Services
{
    public class XboxAuthService
    {
        private IHttpContextAccessor HttpContextAccessor { get; }

        private IHttpClientFactory HttpFactory { get; }

        private HttpContext HttpContext => HttpContextAccessor.HttpContext!;

        private static string RedirectUrl => $"{Constants.Auth.SelfUrl}/callback/xbox";

        private const string Scope = "XboxLive.signin";

        private const string CodeForAccessTokenUrl = "https://login.live.com/oauth20_token.srf";

        private JsonSerializerOptions JsonOptions { get; }

        public XboxAuthService(IHttpContextAccessor httpContextAccessor, IHttpClientFactory factory)
        {
            HttpContextAccessor = httpContextAccessor;
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

        internal async Task HandleCallbackAsync(string code, CancellationToken cancellationToken)
        {
            var (claims, stsTokenResponse) = await ExchangeCodeForAccessTokenAsync(code, cancellationToken);
            
            // check darktide
            await CheckForDarktideAsync(claims, stsTokenResponse.Token, cancellationToken);

            // return with JWT token
        }

        record AchivementHistoryResponseTitle(
            string lastUnlock,
            int titleId,
            string serviceConfigId,
            string titleType,
            string platform,
            string name,
            int earnedAchievements,
            int currentGamerscore,
            int maxGamerscore
        );

        class AchivementHistoryResponse: XboxGetBase
        {
            public AchivementHistoryResponseTitle[] titles { get; set; }
        }

        record XboxGetBasePagingInfo(string continuationToken, int totalRecords);

        class XboxGetBase
        {
            public XboxGetBasePagingInfo pagingInfo { get; set; }
        }

        private async Task CheckForDarktideAsync(UserTokenResponseClaimsItem item, string token, CancellationToken cancellationToken)
        {
            var client = HttpFactory.CreateClient();
            client.DefaultRequestHeaders.Add("X-Xbl-Contract-Version", "2");
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("XBL3.0", $"x={item.uhs};{token}");

            var response = await client.GetAsync($"https://achievements.xboxlive.com/users/xuid({item.xid})/history/titles", cancellationToken);
            // TODO: use continuation token
            response.EnsureSuccessStatusCode();
            var history = (await response.Content.ReadFromJsonAsync<AchivementHistoryResponse>(cancellationToken))!;
            const long darkideId = 1684508835;
            if (history.titles.Any(x => x.titleId == darkideId))
            {
                return;
            }

            // TODO: dig through api for Darktide related info
            // https://learn.microsoft.com/en-us/gaming/gdk/_content/gc/reference/live/rest/uri/atoc-xboxlivews-reference-uris
        }

#pragma warning disable IDE1006

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
                var response = await client.PostAsJsonAsync("https://user.auth.xboxlive.com/user/authenticate", request, JsonOptions, cancellationToken);
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
                var response = await client.PostAsJsonAsync("https://xsts.auth.xboxlive.com/xsts/authorize", request, JsonOptions, cancellationToken);
                response.EnsureSuccessStatusCode();
                stsTokenResponse = (await response.Content.ReadFromJsonAsync<UserTokenResponse>(cancellationToken))!;
            }

            return (stsTokenResponse.DisplayClaims.xui[0], stsTokenResponse);
        }
    }
}
