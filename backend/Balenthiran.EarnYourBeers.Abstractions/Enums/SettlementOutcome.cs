namespace Balenthiran.EarnYourBeers.Abstractions.Enums;

/// <summary>What a weekly settlement did to the tier (BEH-SETTLE-1, BEH-SETTLE-2).</summary>
public enum SettlementOutcome
{
    PositionSecured = 0,
    Promoted = 1,
    DoublePromotion = 2,
    Demoted = 3,
}
