﻿using AspNet.Security.OpenId.Steam;
using Microsoft.AspNetCore.Authentication;

namespace Api.Services
{
    public record GetOwnedGamesGame(int? AppId/*, ... */);
    public record GetOwnedGamesResponse(GetOwnedGamesGame[]? Games/*, ... */);
    public record GetOwnedGamesResponseType(GetOwnedGamesResponse? Response);

    public class SteamAuthService : AuthServiceBase
    {
        public SteamAuthService(IHttpContextAccessor httpContextAccessor) : base(httpContextAccessor) { }

        public async Task ChallengeAsync()
        {
            var properties = new AuthenticationProperties()
            {
                RedirectUri = "/callback/steam",
            };
            await HttpContext.ChallengeAsync(SteamAuthenticationDefaults.AuthenticationScheme, properties);
        }

        internal async Task HandleCallbackAsync()
        {
            // Validate via Steam
            var type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier";
            var steamIdPrefix = "https://steamcommunity.com/openid/id/";
            var steamIdRaw = HttpContext.User.Claims.FirstOrDefault(x => x.Type == type && x.Value.StartsWith(steamIdPrefix))
                ?? throw new AuthException(InternalError.SteamClaimMissing);
            var steamId = steamIdRaw.Value[steamIdPrefix.Length..];

            // Get owned games
            var ownedGamesUrl =
                "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?" +
                $"key={Constants.Auth.SteamWebApiKey}&format=json&steamid={steamId}";
            var httpClient = new HttpClient();
            var response = await httpClient.GetAsync(ownedGamesUrl);
            if (!response.IsSuccessStatusCode)
                throw new AuthException(InternalError.SteamGetOwnedGamesError, response.StatusCode);
            var ownedGamesType = await response.Content.ReadFromJsonAsync<GetOwnedGamesResponseType>();
            var ownsDarktide = ownedGamesType?.Response?.Games?
                .Any(x => x.AppId == Constants.Auth.SteamDarktideId) == true;
            if (!ownsDarktide)
                throw new AuthException(InternalError.SteamNoOwnership);

            // Create token
            // No need to lower steamId for normalization as it's numeric
            RedirectToWebsiteWithAccessToken(AuthenticationType.Steam, steamId);
        }
    }
}
