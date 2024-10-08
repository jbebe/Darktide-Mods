using Api.Services;
using Api.Services.Models;

namespace Api.Database
{
    public interface IDatabaseService
    {
        IRating CreateRating(string id, Dictionary<string, Rater> ratings, DateTime created);

        IAccount CreateAccount(string id, int characterLevel, string reef, string[] friends, DateTime created);

        Task CreateOrUpdateRatingAsync(IRating entity, CancellationToken cancellationToken);

        Task CreateOrUpdateAccountAsync(IAccount entity, CancellationToken cancellationToken);

        Task<IRating?> GetRatingAsync(string id, CancellationToken cancellationToken);

        Task<IAccount?> GetAccountAsync(string id, CancellationToken cancellationToken);

        Task<List<IRating>> GetRatingsAsync(CancellationToken cancellationToken);
    }
}
