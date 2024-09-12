using Microsoft.AspNetCore.Mvc.Testing;
using System.Net.Http.Json;

namespace Test
{
    public class BasicTests : IClassFixture<WebApplicationFactory<Api.Program>>
    {
        private HttpClient Client { get; }

        public BasicTests(WebApplicationFactory<Api.Program> factory)
        {
            Client = factory.CreateClient();
        }

        [Fact]
        public void Test1()
        {
            Client.GetFromJsonAsync<>
        }
    }
}