using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http.Features;
using System.Net;

namespace Api
{
    public enum InternalError
    {
        Unknown,

        //
        // Auth errors
        //

        // Steam user id claim is missing, can't proceed further
        SteamClaimMissing,
        // Auth or other error during GetOwnedGames call
        SteamGetOwnedGamesError,
        // User does not own Darktide in Steam
        SteamNoOwnership,
        // User cancelled the authorization flow
        AuthCancelled,
        // Generic Xbox login error
        XboxLoginError,
        // Generic Xbox error during token exchange
        XboxTokenExchangeError,
        // Error during getting the achivements
        XboxGetAchivementsError,
        // User does not own Darktide in Xbox
        XboxNoOwnership,

        //
        // Mod errors
        //
        
        // User rated themself with a forged api call
        SelfRating,

        // Jwt token valid, but missing platform id
        CallerIdMissing
    }

    public enum PublicError
    {
        Internal,
        NoOwnership,
        AuthCancelled,
        UserError,
    }

    public static class InternalErrorExtensions
    {
        public static PublicError ToPublic(this InternalError internalError)
        {
            switch (internalError)
            {
                case InternalError.Unknown:
                case InternalError.SteamClaimMissing:
                case InternalError.SteamGetOwnedGamesError:
                case InternalError.XboxLoginError:
                case InternalError.XboxTokenExchangeError:
                case InternalError.XboxGetAchivementsError:
                case InternalError.CallerIdMissing:
                    return PublicError.Internal;
                
                case InternalError.SteamNoOwnership:
                case InternalError.XboxNoOwnership:
                    return PublicError.NoOwnership;
                
                case InternalError.AuthCancelled:
                    return PublicError.AuthCancelled;

                case InternalError.SelfRating:
                    return PublicError.UserError;

                default:
                    return PublicError.Internal;
            }
        }
    }

    public class LovesMeNotException(
        InternalError errorCode, 
        HttpStatusCode? statusCode,
        Exception? exception
    ) : Exception()
    {
        public InternalError ErrorCode { get; } = errorCode;

        public HttpStatusCode? StatusCode { get; } = statusCode;
        
        public Exception? Exception { get; } = exception;

        public override string ToString()
        {
            return $"ErrorCode: {ErrorCode}" + (StatusCode != null ? $" Status: {(int)StatusCode}" : "");
        }
    }

    public class AuthException(
        InternalError code, 
        HttpStatusCode? statusCode = null, 
        Exception? exception = null
    ) : LovesMeNotException(code, statusCode, exception);

    public class ModException(InternalError code) 
        : LovesMeNotException(code, statusCode: null, exception: null);

    public class CustomExceptionHandler(ILogger<Program> logger) : IExceptionHandler
    {
        public ILogger<Program> Logger { get; } = logger;

        public ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
        {
            Logger.LogError(exception, message: null);
            var pathFeature = httpContext.Features.GetRequiredFeature<IExceptionHandlerPathFeature>();

            if (pathFeature.Path.StartsWith("/auth/") || pathFeature.Path.StartsWith("/callback/"))
            {
                var code = PublicError.Internal;
                if (exception is AuthException authEx)
                {
                    code = authEx.ErrorCode.ToPublic();
                }
                httpContext.Response.Redirect(Constants.Auth.WebsiteUrlWithError(code), permanent: false);
                
                return ValueTask.FromResult(true);
            }

            if (pathFeature.Path == $"/{Constants.ApiVersion}/ratings")
            {
                var code = PublicError.Internal;
                if (exception is ModException modEx)
                {
                    code = modEx.ErrorCode.ToPublic();
                }

                httpContext.Response.WriteAsync(code.ToString(), cancellationToken);

                return ValueTask.FromResult(true);
            }

            return ValueTask.FromResult(false);
        }
    }
}