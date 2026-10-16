namespace Balenthiran.EarnYourBeers.Abstractions.DomainModels;

using Balenthiran.EarnYourBeers.Abstractions.DataModels;

public interface IDomainStatus : IStatus
{
    string GetFriendlyStatus();
}
