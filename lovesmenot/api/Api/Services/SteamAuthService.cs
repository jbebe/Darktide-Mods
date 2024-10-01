using AspNet.Security.OpenId.Steam;
using Microsoft.AspNetCore.Authentication;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Text;

namespace Api.Services
{
    public record GetOwnedGamesGame(int? AppId/*, ... */);
    public record GetOwnedGamesResponse(GetOwnedGamesGame[]? Games/*, ... */);
    public record GetOwnedGamesResponseType(GetOwnedGamesResponse? Response);

    public class SteamAuthService
    {
        private IHttpContextAccessor HttpContextAccessor { get; }

        private HttpContext HttpContext => HttpContextAccessor.HttpContext!;

        public SteamAuthService(IHttpContextAccessor httpContextAccessor)
        {
            HttpContextAccessor = httpContextAccessor;
        }

        public async Task ChallengeAsync()
        {
            var properties = new AuthenticationProperties()
            {
                RedirectUri = "/callback/steam",
            };
            await HttpContext.ChallengeAsync(SteamAuthenticationDefaults.AuthenticationScheme, properties);
        }

        internal async Task<string> HandleCallbackAsync()
        {
            // Validate via Steam
            var type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier";
            var steamIdPrefix = "https://steamcommunity.com/openid/id/";
            var steamIdRaw = HttpContext.User.Claims.Single(x => x.Type == type && x.Value.StartsWith(steamIdPrefix));
            var steamId = steamIdRaw.Value[steamIdPrefix.Length..];
            
            // Get owned games
            var ownedGamesUrl = 
                "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?" + 
                $"key={Constants.Secrets.SteamWebApiKey}&format=json&steamid={steamId}";
            var httpClient = new HttpClient();
            var response = await httpClient.GetAsync(ownedGamesUrl);
            response.EnsureSuccessStatusCode();
            var ownedGamesType = await response.Content.ReadFromJsonAsync<GetOwnedGamesResponseType>();
            var darktideAppId = 1361210;
            var ownsDarktide = ownedGamesType?.Response?.Games?.Any(x => x.AppId == darktideAppId) == true;
            if (!ownsDarktide) throw new Exception();

            // Create token
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Constants.Secrets.JwtKey));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                Constants.JwtIssuer,
                Constants.JwtIssuer,
                null,
                expires: DateTime.Now.AddYears(1),
                signingCredentials: credentials);

            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);

            return tokenString;
        }
    }
}
