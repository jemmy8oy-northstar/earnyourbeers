using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Exceptions;

namespace Balenthiran.EarnYourBeers.Services;

/// <summary>
/// BEH-ONBOARD-1/2, ported from lib/ui/screens/onboarding_screen.dart:471-487 (the form's sliders at
/// :264-268 and :338-342 give the ranges). The step bands in app_state.dart:438 are dead code and
/// are not ported.
/// </summary>
public static class Seeding
{
    public const int MaxViceCount = 40;
    private const double LogStep = 0.23025; // onboarding_screen.dart:477, "-log(0.7943)"
    private const int MaxTier = 20;

    public static double MaxVolume(ActivityType sport) => sport switch
    {
        ActivityType.Run => 100,
        ActivityType.Cycle => 300,
        ActivityType.Swim => 3000,
        _ => throw new ValidationException("Pick a sport: Run, Cycle or Swim."),
    };

    public static void Validate(ActivityType sport, double weeklyVolume, double weeklyViceCount)
    {
        if (!Enum.IsDefined(sport) || !double.IsFinite(weeklyVolume) || weeklyVolume < 0 || weeklyVolume > MaxVolume(sport))
        {
            throw new ValidationException($"Weekly volume must be between 0 and {MaxVolume(sport)} for {sport}.");
        }

        if (!double.IsFinite(weeklyViceCount) || weeklyViceCount < 0 || weeklyViceCount > MaxViceCount)
        {
            throw new ValidationException($"Weekly vice count must be between 0 and {MaxViceCount}.");
        }
    }

    /// <summary>
    /// Points at tier 0 are volume × rate × 10. Tier is round(ln(points / 25) / 0.23025) clamped to
    /// 0..20, where Dart's round() is half away from zero and a non-positive point total stays at 0
    /// (:478). If points − vices &lt; −15 the tier drops by 5, floored at 0 (:484-487), and that test
    /// still runs when the points are 0.
    /// </summary>
    public static int StartingLevel(IScoring scoring, ActivityType sport, double weeklyVolume, double weeklyViceCount)
    {
        var points = weeklyVolume * scoring.PointsPerUnit(sport) * 10.0;
        var level = 0;
        if (points > 0)
        {
            var calculated = Math.Log(points / 25.0) / LogStep;
            level = Math.Clamp((int)Math.Round(calculated, MidpointRounding.AwayFromZero), 0, MaxTier);
        }

        if (points - weeklyViceCount < -15)
        {
            level = Math.Clamp(level - 5, 0, MaxTier);
        }

        return level;
    }
}
