
namespace Api.Services.Models
{
    public interface IRating : IEntity
    {
        /// <summary>
        /// Ratings of a single player
        /// </summary>
        Dictionary<string, Rater> Ratings { get; set; }

        /// <summary>
        /// Score of a single player
        /// </summary>
        double Score => Ratings.Values.Sum(Utils.CalculateScore);
    }
}