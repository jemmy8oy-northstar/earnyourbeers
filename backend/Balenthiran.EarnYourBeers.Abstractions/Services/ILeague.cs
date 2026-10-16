using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.Abstractions.Services;

/// <summary>
/// The league: its tiers (BEH-LEAGUE-1), the weekly settlement (BEH-SETTLE-1) and the tier
/// onboarding seeds (BEH-ONBOARD-2). Pure rules, ported from the Flutter app's app_state.dart and
/// onboarding_screen.dart.
/// </summary>
public interface ILeague
{
    /// <summary>The 20 tiers, lowest first: four divisions of five.</summary>
    IReadOnlyList<ILeagueTier> Tiers { get; }

    /// <summary>
    /// Adds the week's net balance to the tally, then: ≥ 50 up two tiers and −50; ≥ 25 up one and
    /// −25; ≤ −25 down one and +25; otherwise it carries over. The level is clamped to the tiers.
    /// </summary>
    ISettlementResult Settle(int level, double tally, double weeklyNet);

    /// <summary>The banner's bar: a tally of −25..+25 mapped to 0..1, clamped.</summary>
    double TallyProgress(double tally);

    /// <summary>
    /// The tier onboarding starts someone on: round(ln(points / 25) / 0.23025) clamped to 0..20,
    /// where points = weekly volume × base rate × 10; five lower (floored at 0) when
    /// points − weekly vices &lt; −15.
    /// </summary>
    int StartingLevel(ActivityType sport, double weeklyVolume, int weeklyVices);
}
