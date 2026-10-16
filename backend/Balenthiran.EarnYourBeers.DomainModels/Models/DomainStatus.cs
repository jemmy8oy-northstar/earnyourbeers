using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.DataModels.Models;

namespace Balenthiran.EarnYourBeers.DomainModels.Models;

public class DomainStatus : Status, IDomainStatus
{
    public string GetFriendlyStatus()
    {
        return $"System is running version {Version} (Updated: {LastUpdated:g})";
    }
}
