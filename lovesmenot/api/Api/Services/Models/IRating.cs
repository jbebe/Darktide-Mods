
namespace Api.Services.Models
{
    public interface IRating : IEntity
    {
        Dictionary<string, Rater> Ratings { get; }
        
        double Score => Ratings.Values.Sum(Utils.CalculateScore);
    }
}