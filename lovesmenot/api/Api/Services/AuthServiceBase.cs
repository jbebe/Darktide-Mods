using Microsoft.IdentityModel.Tokens;
using System;
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

        internal protected static (string AccessToken, string Hash) CreateAccessToken(AuthenticationType type, string platformId)
        {
            var credentials = new SigningCredentials(Constants.Auth.JwtSignerKey, SecurityAlgorithms.RsaSha256);
            byte[] hashBytes = MD5.HashData(Encoding.ASCII.GetBytes($"{type.ToString().ToLower()}:{platformId}"));
            var hashedId = Convert.ToHexString(hashBytes).ToLowerInvariant();
            var token = new JwtSecurityToken(
                issuer: Constants.Auth.JwtIssuer,
                claims: [new Claim(type: Constants.Auth.PlatformId, value: hashedId)],
                expires: DateTime.Now.AddYears(1),
                signingCredentials: credentials
            );
            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);

            return (tokenString, hashedId);
        }

        protected void RedirectToWebsiteWithAccessToken(AuthenticationType type, string platformId)
        {
            var tokenString = CreateAccessToken(type, platformId);
            var typedUrl = Constants.Auth.WebsiteUrlWithTyped(type);
            HttpContext.Response.Redirect($"{typedUrl}#token={tokenString}", permanent: false);
        }
    }
}
