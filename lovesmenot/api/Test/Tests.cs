using Api.Controllers.Models;
using Bogus;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net.Http.Json;

namespace Test
{
    public class BasicTests : IClassFixture<ApplicationFactory>
    {
        private HttpClient Client { get; }

        private Faker Faker { get; }

        public BasicTests(ApplicationFactory factory)
        {
            Client = factory.CreateClient();
            Faker = new Faker();
        }

        [Fact]
        public async Task CreateRatingAsync()
        {
            var message = await Client.GetStringAsync("/");
            await Client.PostAsJsonAsync("/raaaaaaaaatings", new RatingRequest
            {
                SourceHash = Faker.Random.Hash(32),
                SourceXp = 1,
                TargetXp = 1,
                Type = Api.RatingType.Negative,
                Region = $"aws-{Faker.Random.AlphaNumeric(10)}",
                TargetHash = Faker.Random.Hash(32),
            }, CancellationToken.None);
        }
    }
}