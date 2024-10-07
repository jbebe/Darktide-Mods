using Microsoft.AspNetCore.Diagnostics;

namespace Api
{
    public class CustomExceptionHandler : IExceptionHandler
    {
        public ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
        {
            return ValueTask.FromResult(false);
        }
    }
}