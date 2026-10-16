namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>The settlement report still to be dismissed (BEH-SETTLE-2).</summary>
public record SettlementResponse(double WeeklyNet, string Outcome);
