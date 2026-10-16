using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.Services;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>
/// BEH-SCORE-1 and BEH-SCORE-2. The oracle is the Flutter app's code (pint_calculator.dart,
/// app_state.dart:268), not its tests or README, which still say 3 points a km.
/// </summary>
public class ScoringTests
{
    private readonly IScoring _scoring = new Scoring();

    [Theory]
    [InlineData(ActivityType.Run, 0.5)]
    [InlineData(ActivityType.Cycle, 1.0 / 6.0)]
    [InlineData(ActivityType.Swim, 1.0 / 60.0)]
    public void Each_activity_earns_its_rate_per_unit(ActivityType type, double expected)
        => Assert.Equal(expected, _scoring.PointsPerUnit(type));

    [Fact]
    public void An_unknown_activity_earns_nothing()
        => Assert.Equal(0, _scoring.PointsPerUnit((ActivityType)99));

    [Theory]
    [InlineData(0, 10.0)]
    [InlineData(10, 1.0)]
    [InlineData(20, 0.1)]
    public void Difficulty_runs_from_ten_times_at_tier_zero_to_a_tenth_at_tier_twenty(int level, double expected)
        => Assert.Equal(expected, _scoring.Difficulty(level), 3);

    [Fact]
    public void At_tier_zero_a_km_run_is_worth_five_points()
        => Assert.Equal(5.0, _scoring.PointsPerUnit(ActivityType.Run) * _scoring.Difficulty(0), 9);

    [Fact]
    public void Difficulty_scales_activity_and_never_the_vice()
    {
        // 10 km run = 5 raw points; at tier 10 (×1.0) that is 5, less 3 vices = 2.
        Assert.Equal(2.0, _scoring.Balance(5, 3, 10), 3);

        // The same week at tier 0 (×10): 50 − 3.
        Assert.Equal(47.0, _scoring.Balance(5, 3, 0), 9);
    }

    [Fact]
    public void Vices_alone_are_debt_one_point_each()
        => Assert.Equal(-4.0, _scoring.Balance(0, 4, 7));
}
