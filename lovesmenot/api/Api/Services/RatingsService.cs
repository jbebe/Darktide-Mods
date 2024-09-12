
using Api.Controllers.Models;
using Api.Services.Models;
using System.Threading;

namespace Api.Services
{
    public class RatingsService
    {
        private IDatabaseService Db { get; }

        public RatingsService(IDatabaseService db)
        {
            Db = db;
        }

        public IAsyncEnumerable<Rating> GetRatingsAsync(CancellationToken cancellationToken)
        {
            var ratings = Db.GetRatingsAsync(cancellationToken);
            throw new NotImplementedException();
        }

        public async Task AddRatingAsync(RatingRequest request, CancellationToken cancellationToken)
        {
            var id = request.Hash;
            var rating = await Db.GetRatingAsync(id, cancellationToken);
            var now = DateTime.UtcNow;

            if (rating == null)
            {
                rating = new Rating
                {
                    Type = request.Type,
                    Hash = request.Hash,
                    Metadata = new Metadata
                    {
                        Regions = request.Region != null ? [request.Region] : null,
                    },
                    Created = now,
                    Updated = null,
                };
            }
            else
            {
                
            }

            
            
        }
    }
}
