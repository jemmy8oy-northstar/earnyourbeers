using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.Abstractions.Services;

/// <summary>
/// How activity earns points and a vice spends them (BEH-SCORE-1, BEH-SCORE-2). Pure rules, ported
/// from the Flutter app's pint_calculator.dart and app_state.dart; the code's numbers, not the docs'.
/// </summary>
public interface IScoring
{
    /// <summary>Points one unit earns before difficulty: run 0.5 a km, cycle 1/6 a km, swim 1/60 a length.</summary>
    double PointsPerUnit(ActivityType type);

    /// <summary>The league's multiplier on activity points: 10 × 0.794328^level.</summary>
    double Difficulty(int level);

    /// <summary>
    /// (activity points × difficulty) − vice units. <paramref name="activityPoints"/> is the sum of
    /// amount × <see cref="PointsPerUnit"/>; a vice always costs exactly 1 point a unit.
    /// </summary>
    double Balance(double activityPoints, double viceUnits, int level);
}
