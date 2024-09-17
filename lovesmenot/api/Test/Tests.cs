using Api.Controllers.Models;
using Api.Services;
using Bogus;
using Microsoft.Extensions.DependencyInjection;

namespace Test
{
    public class BasicTests : IClassFixture<ApplicationFactory>, IDisposable
    {
        private HttpClient Client { get; }

        private Faker Faker { get; }

        private MockDatabaseService DbService { get; }

        public BasicTests(ApplicationFactory factory)
        {
            Client = factory.CreateClient();
            Faker = new Faker();
            DbService = (factory.Services.GetRequiredService<IDatabaseService>() as MockDatabaseService)!;
        }

        public void Dispose()
        {
            DbService.Db.Clear();
        }

        private RatingRequest CreateRequest()
        {
            return new RatingRequest
            {
                SourceHash = Faker.Random.Hash(32),
                SourceXp = Faker.Random.Int(1, 500_000),
                TargetXp = Faker.Random.Int(1, 500_000),
                Type = Faker.Random.Enum<Api.RatingType>(),
                Region = $"aws-{Faker.Random.AlphaNumeric(10)}",
                TargetHash = Faker.Random.Hash(32),
            };
        }

        [Fact]
        public async Task HealthCheck_Success()
        {
            var response = await Client.GetAsync("/");
            response.EnsureSuccessStatusCode();
            Assert.False(string.IsNullOrEmpty(await response.Content.ReadAsStringAsync()));
        }

        [Fact]
        public async Task CreateRating_Success()
        {
            Assert.Empty(DbService.Db);

            var startDate = DateTime.UtcNow;
            var request = await Client.CreateRatingAsync(CreateRequest(), CancellationToken.None);
            var endDate = DateTime.UtcNow;

            var rating = Assert.Single(DbService.Db).Value;
            Assert.Equal(request.TargetHash, rating.Id);
            Assert.InRange(rating.Created, startDate, endDate);
            Assert.Null(rating.Updated);
            Assert.True(request.Type == Api.RatingType.Positive ? (rating.Score > 0) : (rating.Score < 0));

            var region = Assert.Single(rating.Metadata.Regions);
            Assert.Equal(request.Region, region);
            Assert.Equal(request.TargetXp, rating.Metadata.MaxCharacterXp);
            
            var rater = Assert.Single(rating.RatedBy);
            Assert.Equal(request.Type, rater.Type);
            Assert.Equal(request.SourceHash, rater.AccountHash);
            Assert.Equal(request.SourceXp, rater.Xp);
        }

        [Fact]
        public async Task UpdateRating_Success()
        {
            var request = CreateRequest();
            
            // Add rating as player 1
            await Client.CreateRatingAsync(request, CancellationToken.None);
            var rating = Assert.Single(DbService.Db).Value;
            Assert.Equal(request.SourceHash, rating.RatedBy.Single().AccountHash);

            // Add rating as player 2
            request.SourceHash = Faker.Random.Hash(32);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Assert that a second player can rate the target too
            rating = DbService.Db.Single(x => x.Value.Id == request.TargetHash).Value;
            Assert.Equal(2, rating.RatedBy.Count);
            Assert.Equal(request.SourceHash, rating.RatedBy.Single(x => x.AccountHash == request.SourceHash).AccountHash);
        }

        [Fact]
        public async Task GetRatings_Success()
        {
            var ratings = await Client.GetRatingsAsync(CancellationToken.None);
            Assert.Empty(ratings);
        }
    }
}