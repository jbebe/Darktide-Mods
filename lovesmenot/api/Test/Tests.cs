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

        private string DefaultRegion { get; }

        public BasicTests(ApplicationFactory factory)
        {
            Client = factory.CreateClient();
            Faker = new Faker();
            DbService = (factory.Services.GetRequiredService<IDatabaseService>() as MockDatabaseService)!;
            DefaultRegion = $"aws-{Faker.Random.AlphaNumeric(10)}";
        }

        public void Dispose()
        {
            DbService.Db.Clear();
        }

        private RatingRequest CreateRequest(
            string? targetHash = null,
            int? sourceXp = null,
            RatingType? type = null
        )
        {
            return new RatingRequest
            {
                SourceHash = Faker.Random.Hash(32),
                SourceXp = sourceXp ?? Faker.Random.Int(1, 500_000),
                Targets = [
                    new TargetRequest
                    {
                        Type = type ?? Faker.Random.Enum<RatingType>(),
                        TargetXp = Faker.Random.Int(1, 500_000),
                        TargetHash = targetHash ?? Faker.Random.Hash(32),
                    }
                ]
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
            var request = await Client.CreateRatingAsync(DefaultRegion, CreateRequest(), CancellationToken.None);
            var endDate = DateTime.UtcNow;

            var rating = Assert.Single(DbService.Db).Value;
            Assert.Equal(request.Targets.Single().TargetHash, rating.Id);
            Assert.InRange(rating.Created, startDate, endDate);
            Assert.Null(rating.Updated);

            Assert.Equal(request.Targets.Single().TargetXp, rating.Metadata.MaxCharacterXp);
            
            var rater = Assert.Single(rating.RatedBy);
            Assert.Equal(request.Targets.Single().Type, rater.Type);
            Assert.Equal(request.SourceHash, rater.AccountHash);
            Assert.Equal(request.SourceXp, rater.MaxCharacterXp);
        }

        [Fact]
        public async Task UpdateRating_Success()
        {
            var request = CreateRequest();
            
            // Add rating as player 1
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);
            var rating = Assert.Single(DbService.Db).Value;
            Assert.Equal(request.SourceHash, rating.RatedBy.Single().AccountHash);

            // Add rating as player 2
            request.SourceHash = Faker.Random.Hash(32);
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);

            // Assert that a second player can rate the target too
            rating = DbService.Db.Single(x => x.Value.Id == request.Targets.Single().TargetHash).Value;
            Assert.Equal(2, rating.RatedBy.Count);
            Assert.Equal(request.SourceHash, rating.RatedBy.Single(x => x.AccountHash == request.SourceHash).AccountHash);
        }

        [Fact]
        public async Task GetRatings_Everyone_Rates_Negative()
        {
            var targetHash = Faker.Random.Hash(32);

            // Add rating as player 1
            var request = CreateRequest(targetHash, sourceXp: Constants.DecentXp, type: RatingType.Negative);
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);

            // Add rating as player 2
            request = CreateRequest(targetHash, sourceXp: Constants.DecentXp, type: RatingType.Negative);
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);

            // Add rating as player 3
            request = CreateRequest(targetHash, sourceXp: Constants.DecentXp, type: RatingType.Negative);
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);

            // Check ratings (no result yet, only 3 people)
            var ratings = await Client.GetRatingsAsync(DefaultRegion, CancellationToken.None);
            Assert.Empty(ratings);

            // Add rating as player 4
            request = CreateRequest(targetHash, sourceXp: 0);
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);

            // Check ratings (results are available as the fourth vote just came in)
            ratings = await Client.GetRatingsAsync(DefaultRegion, CancellationToken.None);
            var rating = Assert.Single(ratings);
            Assert.Equal(request.Targets.Single().TargetHash, rating.Hash);
            Assert.Equal(RatingType.Negative, rating.Type);
        }

        [Fact]
        public async Task GetRatings_Balanced_Out_No_Rating()
        {
            var targetHash = Faker.Random.Hash(32);

            // Add rating as player 1
            var request = CreateRequest(targetHash, sourceXp: Constants.DecentXp, type: RatingType.Negative);
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);

            // Add rating as player 2
            request = CreateRequest(targetHash, sourceXp: Constants.DecentXp, type: RatingType.Negative);
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);

            // Add rating as player 3
            request = CreateRequest(targetHash, sourceXp: Constants.DecentXp, type: RatingType.Positive);
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);

            // Check ratings (no result yet, only 3 people)
            var ratings = await Client.GetRatingsAsync(DefaultRegion, CancellationToken.None);
            Assert.Empty(ratings);

            // Add rating as player 4
            request = CreateRequest(targetHash, sourceXp: Constants.DecentXp, type: RatingType.Positive);
            await Client.CreateRatingAsync(DefaultRegion, request, CancellationToken.None);

            // Check ratings (results are available as the fourth vote just came in)
            ratings = await Client.GetRatingsAsync(DefaultRegion, CancellationToken.None);
            Assert.Empty(ratings);
        }
    }
}