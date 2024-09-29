using Api;
using Api.Controllers.Models;
using Api.Database;
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

        private RatingRequest CreateRequest(
            string? targetHash = null,
            int? sourceLevel = null,
            RatingType? type = null
        )
        {
            return new RatingRequest
            {
                SourceHash = Faker.Random.Hash(32),
                SourceLevel = sourceLevel ?? Faker.Random.Int(1, 30),
                SourceReef = Faker.PickRandom("eu", "hk", "mei", "sa"),
                Targets = new Dictionary<string, TargetRequest>
                {
                    [targetHash ?? Faker.Random.Hash(32)] = new TargetRequest
                    {
                        Type = type ?? Faker.Random.Enum<RatingType>(),
                        TargetLevel = Faker.Random.Int(1, 30),
                    }
                },
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
            Assert.Equal(request.Targets.Keys.Single(), rating.Id);
            Assert.InRange(rating.Created, startDate, endDate);
            Assert.Null(rating.Updated);

            Assert.Equal(request.Targets.Values.Single().TargetLevel, rating.Metadata.MaxCharacterLevel);
            
            var rater = Assert.Single(rating.RatedBy);
            Assert.Equal(request.Targets.Values.Single().Type, rater.Value.Type);
            Assert.Equal(request.SourceHash, rater.Key);
            Assert.Equal(request.SourceLevel, rater.Value.MaxCharacterLevel);
        }

        [Fact]
        public async Task UpdateRating_Success()
        {
            var request = CreateRequest();
            
            // Add rating as player 1
            await Client.CreateRatingAsync(request, CancellationToken.None);
            var rating = Assert.Single(DbService.Db).Value;
            Assert.Equal(request.SourceHash, rating.RatedBy.Keys.Single());

            // Add rating as player 2
            request.SourceHash = Faker.Random.Hash(32);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Assert that a second player can rate the target too
            rating = DbService.Db.Single(x => x.Value.Id == request.Targets.Keys.Single()).Value;
            Assert.Equal(2, rating.RatedBy.Count);
            Assert.Equal(request.SourceHash, rating.RatedBy.Keys.Single(x => x == request.SourceHash));
        }

        [Fact]
        public async Task GetRatings_Everyone_Rates_Negative()
        {
            var targetHash = Faker.Random.Hash(32);

            // Add rating as player 1
            var request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Add rating as player 2
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Add rating as player 3
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Check ratings (no result yet, only 3 people)
            var ratings = await Client.GetRatingsAsync(CancellationToken.None);
            Assert.Empty(ratings);

            // Add rating as player 4
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Check ratings (results are available as the fourth vote just came in)
            ratings = await Client.GetRatingsAsync(CancellationToken.None);
            var rating = Assert.Single(ratings);
            Assert.Equal(request.Targets.Keys.Single(), rating.Key);
            Assert.Equal(RatingType.Negative, rating.Value);
        }

        [Fact]
        public async Task GetRatings_Everyone_Rates_Negative_Too_Few_Players()
        {
            var targetHash = Faker.Random.Hash(32);

            // Add rating as player 1
            var request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Add rating as player 2
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Add rating as player 3
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Add rating as player 4
            request = CreateRequest(targetHash, sourceLevel: 1);
            request = CreateRequest(targetHash, sourceLevel: 11);
            request = CreateRequest(targetHash, sourceLevel: 29);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Check ratings (more than 4 players but only 3 lvl30 player, so it's still not 4x30...
            var ratings = await Client.GetRatingsAsync(CancellationToken.None);
            Assert.Empty(ratings);
        }

        [Fact]
        public async Task GetRatings_Balanced_Out_No_Rating()
        {
            var targetHash = Faker.Random.Hash(32);

            // Add rating as player 1
            var request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Add rating as player 2
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Add rating as player 3
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Positive);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Check ratings (no result yet, only 3 people)
            var ratings = await Client.GetRatingsAsync(CancellationToken.None);
            Assert.Empty(ratings);

            // Add rating as player 4
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Positive);
            await Client.CreateRatingAsync(request, CancellationToken.None);

            // Check ratings (results are available as the fourth vote just came in)
            ratings = await Client.GetRatingsAsync(CancellationToken.None);
            Assert.Empty(ratings);
        }
    }
}