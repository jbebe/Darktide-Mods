using Microsoft.AspNetCore.WebUtilities;

namespace Api.Services
{
    public class XboxAuthService
    {
        private IHttpContextAccessor HttpContextAccessor { get; }

        private HttpContext HttpContext => HttpContextAccessor.HttpContext!;

        public XboxAuthService(IHttpContextAccessor httpContextAccessor)
        {
            HttpContextAccessor = httpContextAccessor;
        }

        public void Challenge()
        {
            var query = new Dictionary<string, string?>
            {
                ["client_id"] = Constants.Auth.XboxClientId,
                ["redirect_uri"] = "/callback/xbox",
                ["response_type"] = "code",
                ["scope"] = "XboxLive.signin"
            };
            var authUrl = QueryHelpers.AddQueryString("https://login.live.com/oauth20_authorize.srf", query);
            HttpContext.Response.Redirect(authUrl, permanent: false);
        }

        internal async Task HandleCallbackAsync(string code)
        {

            // Constants.Auth.WebsiteUrlTyped(AuthenticationType.Xbox)
        }
    }
}
