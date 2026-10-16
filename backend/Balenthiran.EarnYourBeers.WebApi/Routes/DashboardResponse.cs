namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>Everything the dashboard draws (BEH-BALANCE-1, BEH-LEAGUE-1, BEH-LOG-1, BEH-HISTORY-1, BEH-SETTLE-2).</summary>
public record DashboardResponse(
    bool Onboarded,
    string ViceEmoji,
    LeagueResponse League,
    IReadOnlyDictionary<string, double> PointsPerUnit,
    WeekResponse Week,
    SettlementResponse? Settlement);
