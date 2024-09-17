using Api.Services;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace Test
{
    public class ApplicationFactory : WebApplicationFactory<Program>
    {
        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
            builder.ConfigureServices(services =>
            {
                // Replace database service
                var descriptor = new ServiceDescriptor(
                    typeof(IDatabaseService), typeof(MockDatabaseService), ServiceLifetime.Singleton);
                services.Replace(descriptor);
            });

            builder.UseEnvironment("Development");
        }
    }
}
