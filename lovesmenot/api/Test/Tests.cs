using Api;
using Api.Controllers.Models;
using Api.Database;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Test
{
    public class BasicTests : IClassFixture<ApplicationFactory>, IDisposable
    {
        private HttpClient Client { get; }

        private Bogus.Faker Faker { get; }

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
            Faker = new Bogus.Faker();
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
            string[]? friends = null,
            bool? delete = null
        )
        {
            return new RatingRequest
            {
                CharacterLevel = sourceLevel ?? Faker.Random.Int(1, 30),
                Reef = Faker.PickRandom("eu", "hk", "mei", "sa"),
                Updates = delete == true ? null : new Dictionary<string, TargetRequest>
                {
                    [targetHash ?? Faker.Random.Hash(32)] = new TargetRequest
                    {
                        Type = type ?? Faker.Random.Enum<RatingType>(),
                        CharacterLevel = Faker.Random.Int(1, 30),
                    }
                },
                Deletes = delete == true ? [targetHash] : null,
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
            Assert.Equal(request.Updates?.Single().Value.Type, rating.Ratings.Single().Value.Rating);
            Assert.InRange(rating.Ratings.Single().Value.Update, startDate, endDate);

            // Check account
            var rater = DbService.AccountsDb.Single(x => x.Key == raterId).Value;
            Assert.Equal(request.Reef, rater.Reefs.Single());
            Assert.InRange(rater.Created, startDate, endDate);
            Assert.Equal(request.CharacterLevel, rater.CharacterLevel);
            var rated = DbService.AccountsDb.Single(x => x.Key == request.Updates?.Single().Key).Value;
            Assert.Equal(request.Reef, rated.Reefs.Single());
            Assert.InRange(rated.Created, startDate, endDate);
            Assert.Equal(request.Updates?.Single().Value.CharacterLevel, rated.CharacterLevel);
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
            Assert.Equal(request.Updates?.Keys.Single(), rating.Key);
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

        [Fact]
        public async Task UpdateRating_Cannot_Vote_Self()
        {
            var targetHash = Faker.Random.Hash(32);

            var (jwt, sourceHash) = RandomAccessToken;
            var request = CreateRequest(sourceHash, sourceLevel: Constants.MaxLevel, type: RatingType.Positive);
            await Assert.ThrowsAsync<HttpRequestException>(async () =>
            {
                await Client.CreateRatingAsync(jwt, request, CancellationToken.None);
            });
        }

        [Fact]
        public async Task UpdateRating_Revoke_Rating()
        {
            var targetHash = Faker.Random.Hash(32);

            // Add rating
            var request = CreateRequest(targetHash);
            var (jwt, sourceHash) = RandomAccessToken;
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Assert that the rating exists
            Assert.Single(DbService.RatingsDb.Single().Value.Ratings);

            // Revoke rating
            request = CreateRequest(targetHash, delete: true);
            await Client.CreateRatingAsync(jwt, request, CancellationToken.None);

            // Assert that the rating is deleted
            Assert.Empty(DbService.RatingsDb.Single().Value.Ratings);
        }

        class RetryCallback(int retries)
        {
            public class RetryException : Exception { }

            private int Counter = 0;

            public int Retries = retries;

            public Task DoAsync()
            {
                if (Counter < Retries)
                {
                    Counter += 1;
                    throw new RetryException();
                }
                return Task.CompletedTask;
            }
        }

        [Fact]
        public async Task Utils_RetryOnExceptionAsync()
        {
            var ct = CancellationToken.None;

            // Success on first run
            var retry = new RetryCallback(0);
            var result = await Utils.RetryOnExceptionAsync<Exception>(retry.DoAsync, ct);
            Assert.Equal((true, false), result);

            // Success on second run
            retry = new RetryCallback(1);
            result = await Utils.RetryOnExceptionAsync<Exception>(retry.DoAsync, ct);
            Assert.Equal((true, true), result);

            // Success on third run
            retry = new RetryCallback(2);
            result = await Utils.RetryOnExceptionAsync<Exception>(retry.DoAsync, ct);
            Assert.Equal((true, true), result);

            // Fail on any run
            await Assert.ThrowsAsync<NotImplementedException>(async () =>
            {
                await Utils.RetryOnExceptionAsync<ArgumentException>(() =>
                {
                    throw new NotImplementedException();
                }, ct);
            });
        }
    }
}