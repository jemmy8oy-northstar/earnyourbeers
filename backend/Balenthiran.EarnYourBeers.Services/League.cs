using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.DomainModels.Models;

namespace Balenthiran.EarnYourBeers.Services;

/// <summary>
/// BEH-LEAGUE-1, BEH-SETTLE-1 and BEH-ONBOARD-2, ported from lib/core/logic/app_state.dart:23-148,
/// 385-410 and lib/ui/screens/onboarding_screen.dart:471-487.
/// </summary>
public class League(IScoring scoring) : ILeague
{
    private const double PromoteAt = 25;
    private const double DoublePromoteAt = 50;
    private const double SeedPoints = 25;
    private const double SeedStep = 0.23025;
    private const int MaxSeedLevel = 20;
    private const double UnsustainableBelow = -15;
    private const int UnsustainableDrop = 5;

    private static readonly IReadOnlyList<ILeagueTier> AllTiers =
    [
        new LeagueTier("Noob", "Apprenticeship"),
        new LeagueTier("Novice", "Apprenticeship"),
        new LeagueTier("Weekender", "Apprenticeship"),
        new LeagueTier("Rookie", "Apprenticeship"),
        new LeagueTier("Apprentice", "Apprenticeship"),
        new LeagueTier("Regular", "Practice"),
        new LeagueTier("Grinder", "Practice"),
        new LeagueTier("Athlete", "Practice"),
        new LeagueTier("Competitor", "Practice"),
        new LeagueTier("Professional", "Practice"),
        new LeagueTier("Specialist", "Mastery"),
        new LeagueTier("Relentless", "Mastery"),
        new LeagueTier("Veteran", "Mastery"),
        new LeagueTier("Expert", "Mastery"),
        new LeagueTier("Champion", "Mastery"),
        new LeagueTier("Master", "Legacy"),
        new LeagueTier("Grandmaster", "Legacy"),
        new LeagueTier("Elite", "Legacy"),
        new LeagueTier("Titan", "Legacy"),
        new LeagueTier("Legend", "Legacy"),
    ];

    public IReadOnlyList<ILeagueTier> Tiers => AllTiers;

    public ISettlementResult Settle(int level, double tally, double weeklyNet)
    {
        tally += weeklyNet;
        var (change, outcome) = tally switch
        {
            >= DoublePromoteAt => (2, SettlementOutcome.DoublePromotion),
            >= PromoteAt => (1, SettlementOutcome.Promoted),
            <= -PromoteAt => (-1, SettlementOutcome.Demoted),
            _ => (0, SettlementOutcome.PositionSecured),
        };

        tally -= change * PromoteAt;
        return new SettlementResult(Math.Clamp(level + change, 0, AllTiers.Count - 1), tally, outcome);
    }

    public double TallyProgress(double tally) => Math.Clamp((tally + PromoteAt) / (2 * PromoteAt), 0, 1);

    public int StartingLevel(ActivityType sport, double weeklyVolume, int weeklyVices)
    {
        var points = weeklyVolume * scoring.PointsPerUnit(sport) * scoring.Difficulty(0);
        var level = points > 0
            ? Math.Clamp((int)Math.Round(Math.Log(points / SeedPoints) / SeedStep, MidpointRounding.AwayFromZero), 0, MaxSeedLevel)
            : 0;

        return points - weeklyVices < UnsustainableBelow ? Math.Max(level - UnsustainableDrop, 0) : level;
    }
}
