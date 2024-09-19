
namespace Api.Services.Models
{
    public interface IRating
    {
        string EntityType { get; set; }

        string Id { get; init; }

        DateTime Created { get; init; }
        
        Metadata Metadata { get; init; }
        
        List<Rater> RatedBy { get; init; }
        
        DateTime? Updated { get; set; }

        double Score => RatedBy.Sum(Utils.CalculateScore);
    }
}