using Balenthiran.EarnYourBeers.Abstractions.DataModels;
using Balenthiran.EarnYourBeers.Abstractions.DomainModels;

namespace Balenthiran.EarnYourBeers.Abstractions.Services;

public interface IStatusService
{
    Task<IDomainStatus> GetSystemStatusAsync();
}
