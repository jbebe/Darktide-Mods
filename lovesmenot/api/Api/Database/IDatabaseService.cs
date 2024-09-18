using Api.Services.Models;

namespace Api.Database
{
    public interface IDatabaseService
    {
        IRating CreateEntity(string region, string id, List<Rater> ratedBy, Metadata metadata);

        Task CreateOrUpdateAsync(IRating rating, CancellationToken cancellationToken);

        Task<IRating?> GetRatingAsync(string region, string id, CancellationToken cancellationToken);

        Task<List<IRating>> GetRatingsAsync(string region, CancellationToken cancellationToken);
    }
}
