using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Services;

namespace Balenthiran.EarnYourBeers.Services;

/// <summary>
/// BEH-SCORE-1 and BEH-SCORE-2, ported from lib/core/logic/pint_calculator.dart:13-48 and
/// app_state.dart:268. The Flutter tests still expect 3, 1 and 0.1 a unit; the code says 0.5, 1/6
/// and 1/60, and the code is what people used.
/// </summary>
public class Scoring : IScoring
{
    private const double DifficultyAtTierZero = 10.0;
    private const double DifficultyStep = 0.794328;

    public double PointsPerUnit(ActivityType type) => type switch
    {
        ActivityType.Run => 0.5,
        ActivityType.Cycle => 1.0 / 6.0,
        ActivityType.Swim => 1.0 / 60.0,
        _ => 0,
    };

    public double Difficulty(int level) => DifficultyAtTierZero * Math.Pow(DifficultyStep, level);

    public double Balance(double activityPoints, double viceUnits, int level)
        => (activityPoints * Difficulty(level)) - viceUnits;
}
