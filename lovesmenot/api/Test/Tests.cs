using Api;
using Api.Controllers.Models;
using Api.Database;
using Bogus;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Test
{
    public class BasicTests : IClassFixture<ApplicationFactory>, IDisposable
    {
        private HttpClient Client { get; }

        private Faker Faker { get; }

        private MockDatabaseService DbService { get; }

        private (string AccessToken, string Id) RandomAccessToken
        {
            get
            {
                var credentials = new SigningCredentials(Constants.Auth.JwtKeyObject, SecurityAlgorithms.HmacSha256);
                var pidHash = Faker.Random.Hash(32);
                var token = new JwtSecurityToken(
                    issuer: Constants.Auth.JwtIssuer,
                    claims: [new Claim(type: Constants.Auth.PlatformId, value: pidHash)],
                    expires: DateTime.Now.AddYears(1),
                    signingCredentials: credentials
                );
                return (new JwtSecurityTokenHandler().WriteToken(token), pidHash);
            }
        }

        public BasicTests(ApplicationFactory factory)
        {
            Client = factory.CreateClient();
            Faker = new Faker();
            DbService = (factory.Services.GetRequiredService<IDatabaseService>() as MockDatabaseService)!;
        }

        public void Dispose()
        {
            DbService.Clear();
        }

        private RatingRequest CreateRequest(
            string? targetHash = null,
            int? sourceLevel = null,
            RatingType? type = null,
            string[]? friends = null
        )
        {
            return new RatingRequest
            {
                CharacterLevel = sourceLevel ?? Faker.Random.Int(1, 30),
                Reef = Faker.PickRandom("eu", "hk", "mei", "sa"),
                Accounts = new Dictionary<string, TargetRequest>
                {
                    [targetHash ?? Faker.Random.Hash(32)] = new TargetRequest
                    {
                        Type = type ?? Faker.Random.Enum<RatingType>(),
                        CharacterLevel = Faker.Random.Int(1, 30),
                    }
                },
                Friends = friends ?? [],
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
            Assert.Empty(DbService.AccountsDb);
            Assert.Empty(DbService.RatingsDb);

            var startDate = DateTime.UtcNow;
            var (jwt, raterId) = RandomAccessToken;
            var request = await Client.CreateRatingAsync(jwt, CreateRequest(), CancellationToken.None);
            var endDate = DateTime.UtcNow;

            // Check rating
            var rating = Assert.Single(DbService.RatingsDb).Value;
            Assert.InRange(rating.Created, startDate, endDate);
            Assert.Equal(rating.Ratings.Single().Key, raterId);
            Assert.Equal(request.Accounts.Single().Value.Type, rating.Ratings.Single().Value.Rating);
            Assert.InRange(rating.Ratings.Single().Value.Update, startDate, endDate);

            // Check account
            var rater = DbService.AccountsDb.Single(x => x.Key == raterId).Value;
            Assert.Equal(request.Reef, rater.Reefs.Single());
            Assert.InRange(rater.Created, startDate, endDate);
            Assert.Equal(request.CharacterLevel, rater.CharacterLevel);
            var rated = DbService.AccountsDb.Single(x => x.Key == request.Accounts.Single().Key).Value;
            Assert.Equal(request.Reef, rated.Reefs.Single());
            Assert.InRange(rated.Created, startDate, endDate);
            Assert.Equal(request.Accounts.Single().Value.CharacterLevel, rated.CharacterLevel);
        }

        [Fact]
        public async Task UpdateRating_Success()
        {
            var request = CreateRequest();

            // Add rating as player 1
            var (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);
            var rating = Assert.Single(DbService.RatingsDb).Value;
            Assert.Equal(sourceHash, rating.Ratings.Keys.Single());

            // Add rating as player 2
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Assert that a second player can rate the target too
            rating = Assert.Single(DbService.RatingsDb).Value;
            Assert.Equal(2, rating.Ratings.Count);
            Assert.Equal(sourceHash, rating.Ratings.Keys.Single(x => x == sourceHash));
        }

        [Fact]
        public async Task GetRatings_Everyone_Rates_Negative()
        {
            var targetHash = Faker.Random.Hash(32);

            // Add rating as player 1
            var request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            var (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Add rating as player 2
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Add rating as player 3
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Check ratings (no result yet, only 3 people)
            var ratings = await Client.GetRatingsAsync(jwt, CancellationToken.None);
            Assert.Empty(ratings);

            // Add rating as player 4
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Check ratings (results are available as the fourth vote just came in)
            ratings = await Client.GetRatingsAsync(jwt, CancellationToken.None);
            var rating = Assert.Single(ratings);
            Assert.Equal(request.Accounts.Keys.Single(), rating.Key);
            Assert.Equal(RatingType.Negative, rating.Value);
        }

        [Fact]
        public async Task GetRatings_Everyone_Rates_Negative_Too_Few_Players()
        {
            var targetHash = Faker.Random.Hash(32);

            // Add rating as player 1
            var request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            var (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Add rating as player 2
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Add rating as player 3
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Add rating as low level player 4
            request = CreateRequest(targetHash, sourceLevel: 1, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Add rating as low level player 5
            request = CreateRequest(targetHash, sourceLevel: 11, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Add rating as low level player 6
            request = CreateRequest(targetHash, sourceLevel: 29, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Check ratings (more than 4 players but only 3 lvl30 player, so it's still not 4x30...
            var ratings = await Client.GetRatingsAsync(jwt, CancellationToken.None);
            Assert.Empty(ratings);

            // Add rating as max level player 7
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Check ratings (more than 4 players but only 3 lvl30 player, so it's still not 4x30...
            ratings = await Client.GetRatingsAsync(jwt, CancellationToken.None);
            Assert.NotEmpty(ratings);
        }

        [Fact]
        public async Task GetRatings_Balanced_Out_No_Rating()
        {
            var targetHash = Faker.Random.Hash(32);

            // Add rating as player 1
            var request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            var (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Add rating as player 2
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Negative);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Add rating as player 3
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Positive);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Check ratings (no result yet, only 3 people)
            var ratings = await Client.GetRatingsAsync(jwt, CancellationToken.None);
            Assert.Empty(ratings);

            // Add rating as player 4
            request = CreateRequest(targetHash, sourceLevel: Constants.MaxLevel, type: RatingType.Positive);
            (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Check ratings (results are available as the fourth vote just came in)
            ratings = await Client.GetRatingsAsync(jwt, CancellationToken.None);
            Assert.Empty(ratings);
        }
    }
}