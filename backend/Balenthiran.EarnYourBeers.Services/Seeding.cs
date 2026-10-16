using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Exceptions;

namespace Balenthiran.EarnYourBeers.Services;

/// <summary>
/// BEH-ONBOARD-1: the ranges the onboarding form accepts, from the sliders in
/// lib/ui/screens/onboarding_screen.dart:237-243 and :341. The tier the answers seed (BEH-ONBOARD-2)
/// is <see cref="League.StartingLevel"/>.
/// </summary>
public static class Seeding
{
    public const int MaxViceCount = 40;

    public static double MaxVolume(ActivityType sport) => sport switch
    {
        ActivityType.Run => 100,
        ActivityType.Cycle => 300,
        ActivityType.Swim => 3000,
        _ => throw new ValidationException("Pick a sport: Run, Cycle or Swim."),
    };

    public static void Validate(ActivityType sport, double weeklyVolume, int weeklyViceCount)
    {
        if (!Enum.IsDefined(sport) || !double.IsFinite(weeklyVolume) || weeklyVolume < 0 || weeklyVolume > MaxVolume(sport))
        {
            throw new ValidationException($"Weekly volume must be between 0 and {MaxVolume(sport)} for {sport}.");
        }

        if (weeklyViceCount < 0 || weeklyViceCount > MaxViceCount)
        {
            throw new ValidationException($"Weekly vice count must be between 0 and {MaxViceCount}.");
        }
    }
}
