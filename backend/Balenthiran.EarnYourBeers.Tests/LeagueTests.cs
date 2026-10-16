using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.Services;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>
/// BEH-LEAGUE-1, BEH-SETTLE-1 and BEH-ONBOARD-2. The settlement cases are the Flutter app's own
/// (test/league_settlement_test.dart), restated as tallies: its balances assume a difficulty of 1
/// at tier 0, which the code stopped using, so only its thresholds still hold.
/// </summary>
public class LeagueTests
{
    private readonly ILeague _league = new League(new Scoring());

    [Fact]
    public void There_are_twenty_tiers_in_four_divisions_of_five()
    {
        Assert.Equal(20, _league.Tiers.Count);
        Assert.Equal(
            ["Apprenticeship", "Practice", "Mastery", "Legacy"],
            _league.Tiers.Select(t => t.Division).Distinct());
        Assert.All(_league.Tiers.GroupBy(t => t.Division), g => Assert.Equal(5, g.Count()));
        Assert.Equal("Noob", _league.Tiers[0].Name);
        Assert.Equal("Legend", _league.Tiers[^1].Name);
    }

    // ---- Settle (league_settlement_test.dart) ----

    [Theory]
    [InlineData(0, 0, 25, 1, 0, SettlementOutcome.Promoted)]          // single promotion at +25
    [InlineData(0, 0, 50, 2, 0, SettlementOutcome.DoublePromotion)]   // double promotion at +50
    [InlineData(0, 0, 10, 0, 10, SettlementOutcome.PositionSecured)]  // stays, and the tally carries
    [InlineData(0, 10, 15, 1, 0, SettlementOutcome.Promoted)]         // ...and the carried 10 counts next week
    [InlineData(1, 0, -25, 0, 0, SettlementOutcome.Demoted)]          // demotion at −25
    [InlineData(3, 0, 60, 5, 10, SettlementOutcome.DoublePromotion)]  // past +50 the rest carries
    [InlineData(3, 0, -24.99, 3, -24.99, SettlementOutcome.PositionSecured)]
    public void A_week_moves_the_tally_and_the_tally_moves_the_tier(
        int level, double tally, double weeklyNet, int expectedLevel, double expectedTally, SettlementOutcome outcome)
    {
        var r = _league.Settle(level, tally, weeklyNet);

        Assert.Equal(expectedLevel, r.Level);
        Assert.Equal(expectedTally, r.Tally, 9);
        Assert.Equal(outcome, r.Outcome);
    }

    [Fact]
    public void The_tier_is_clamped_but_the_tally_is_still_spent()
    {
        var top = _league.Settle(19, 0, 50);
        Assert.Equal(19, top.Level);
        Assert.Equal(0, top.Tally);

        var bottom = _league.Settle(0, 0, -30);
        Assert.Equal(0, bottom.Level);
        Assert.Equal(-5, bottom.Tally, 9);
    }

    [Theory]
    [InlineData(-25, 0)]
    [InlineData(0, 0.5)]
    [InlineData(25, 1)]
    [InlineData(-40, 0)]
    [InlineData(40, 1)]
    public void The_banner_bar_maps_minus_25_to_plus_25_onto_0_to_1(double tally, double expected)
        => Assert.Equal(expected, _league.TallyProgress(tally));

    // ---- StartingLevel (onboarding_screen.dart:471-487) ----

    [Theory]
    [InlineData(ActivityType.Run, 5, 0, 0)]        // 25 points: ln(1) = 0
    [InlineData(ActivityType.Run, 20, 0, 6)]       // 100 points: ln(4)/0.23025 = 6.02
    [InlineData(ActivityType.Run, 100, 0, 13)]     // the slider max: 500 points
    [InlineData(ActivityType.Cycle, 300, 0, 13)]   // the slider max, the same 500
    [InlineData(ActivityType.Swim, 3000, 0, 13)]   // the slider max, the same 500
    [InlineData(ActivityType.Run, 0, 0, 0)]        // no volume, no log of zero
    [InlineData(ActivityType.Run, 1, 0, 0)]        // below 25 points rounds negative, clamped up
    [InlineData(ActivityType.Run, 10000, 0, 20)]   // clamped at 20
    public void Onboarding_seeds_the_tier_from_weekly_volume(ActivityType sport, double volume, int vices, int expected)
        => Assert.Equal(expected, _league.StartingLevel(sport, volume, vices));

    [Theory]
    [InlineData(215, 9)]   // 200 − 215 = −15: not below −15, no drop
    [InlineData(216, 4)]   // 200 − 216 = −16: five tiers lower
    public void An_unsustainable_vice_count_starts_five_tiers_lower(int vices, int expected)
        => Assert.Equal(expected, _league.StartingLevel(ActivityType.Run, 40, vices)); // 200 points → tier 9

    [Fact]
    public void The_drop_is_floored_at_tier_zero()
        => Assert.Equal(0, _league.StartingLevel(ActivityType.Run, 10, 70)); // tier 3, 50 − 70 = −20
}
