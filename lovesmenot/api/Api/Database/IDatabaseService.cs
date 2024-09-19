using Api.Services.Models;

namespace Api.Database
{
    public interface IDatabaseService
    {
        IRating CreateEntity(string id, List<Rater> ratedBy, Metadata metadata);

        Task CreateOrUpdateAsync(IRating rating, CancellationToken cancellationToken);

        Task<IRating?> GetRatingAsync(string id, CancellationToken cancellationToken);

        Task<List<IRating>> GetRatingsAsync(CancellationToken cancellationToken);
    }
}
