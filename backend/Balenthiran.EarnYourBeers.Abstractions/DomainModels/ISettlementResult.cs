using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.Abstractions.DomainModels;

/// <summary>A weekly settlement's result (BEH-SETTLE-1): the new level and tally, and what happened.</summary>
public interface ISettlementResult
{
    int Level { get; }

    double Tally { get; }

    SettlementOutcome Outcome { get; }
}
