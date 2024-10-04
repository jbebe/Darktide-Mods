using Api.Services.Models;

namespace Api.Database.Models
{
    public interface IBaseEntity : IEntity
    {
        static abstract string HashKey { get; }

        int? Version { get; }
    }
}
