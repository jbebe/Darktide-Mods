using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace Api.Services
{
    public abstract class AuthServiceBase
    {
        private IHttpContextAccessor HttpContextAccessor { get; }

        protected HttpContext HttpContext => HttpContextAccessor.HttpContext!;

        public AuthServiceBase(IHttpContextAccessor httpContextAccessor)
        {
            HttpContextAccessor = httpContextAccessor;
        }

        protected void RedirectToWebsiteWithAccessToken(AuthenticationType type, string platformId)
        {
            var credentials = new SigningCredentials(Constants.Auth.JwtKeyObject, SecurityAlgorithms.HmacSha256);
            // steamId is a numeric string so we don't have to lower it
            byte[] hashBytes = MD5.HashData(Encoding.ASCII.GetBytes($"{type.ToString().ToLower()}:{platformId}"));
            var hashedId = Convert.ToHexString(hashBytes).ToLowerInvariant();
            var token = new JwtSecurityToken(
                issuer: Constants.Auth.JwtIssuer,
                claims: [new Claim(type: Constants.Auth.PlatformId, value: hashedId)],
                expires: DateTime.Now.AddYears(1),
                signingCredentials: credentials
            );
            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);

            string typedUrl = Constants.Auth.WebsiteUrlTyped(type);
            HttpContext.Response.Redirect($"{typedUrl}#token={tokenString}", permanent: false);
        }
    }
}
