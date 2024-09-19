
namespace Api.Services.Models
{
    public interface IRating
    {
        string EntityType { get; set; }

        string Id { get; init; }

        DateTime Created { get; init; }
        
        Metadata Metadata { get; init; }

        Dictionary<string, Rater> RatedBy { get; init; }
        
        DateTime? Updated { get; set; }

        double Score => RatedBy.Values.Sum(Utils.CalculateScore);
    }
}