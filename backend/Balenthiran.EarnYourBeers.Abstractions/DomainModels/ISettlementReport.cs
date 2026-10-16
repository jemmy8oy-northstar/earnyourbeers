using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.Abstractions.DomainModels;

/// <summary>What the settlement report shows (BEH-SETTLE-2): the week's net and what it did.</summary>
public interface ISettlementReport
{
    double WeeklyNet { get; }

    SettlementOutcome Outcome { get; }
}
