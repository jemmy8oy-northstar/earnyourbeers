using Balenthiran.EarnYourBeers.Abstractions.DataModels;
using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.DomainModels.Models;

namespace Balenthiran.EarnYourBeers.Services;

public class StatusService : IStatusService
{
    public Task<IDomainStatus> GetSystemStatusAsync()
    {
        IDomainStatus model = new DomainStatus
        {
            Version = "1.1.0-alpha",
            LastUpdated = DateTime.UtcNow
        };
        
        return Task.FromResult(model);
    }
}
