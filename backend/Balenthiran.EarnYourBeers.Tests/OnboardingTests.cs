using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Exceptions;
using Balenthiran.EarnYourBeers.Services;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>BEH-ONBOARD-1/2 and BEH-VICE-1 as pure functions, checked against onboarding_screen.dart:471-487 and vice_settings_dialog.dart.</summary>
public class OnboardingTests
{
    private static readonly League League = new(new Scoring());

    [Theory]
    [InlineData(ActivityType.Run, 100, 0, 13)]   // 500 points: ln(20) / 0.23025 = 13.01
    [InlineData(ActivityType.Run, 50, 0, 10)]    // 250 points: ln(10) / 0.23025 = 10.00
    [InlineData(ActivityType.Run, 10, 0, 3)]     // 50 points: ln(2) / 0.23025 = 3.01
    [InlineData(ActivityType.Run, 5, 0, 0)]      // 25 points: ln(1) = 0
    [InlineData(ActivityType.Run, 1, 0, 0)]      // 5 points: negative, clamped up to 0
    [InlineData(ActivityType.Run, 0, 0, 0)]      // no points at all stays at 0 (:478)
    [InlineData(ActivityType.Run, 0, 40, 0)]     // the -5 offset fires (-40 < -15) but is floored at 0
    [InlineData(ActivityType.Cycle, 300, 0, 13)] // 300 / 6 × 10 = 500 points
    [InlineData(ActivityType.Swim, 3000, 0, 13)] // 3000 / 60 × 10 = 500 points
    [InlineData(ActivityType.Cycle, 30, 40, 3)]  // 50 points, 40 vices: 10 > -15, no offset
    public void The_starting_tier_follows_the_flutter_formula(ActivityType sport, double volume, int vices, int tier)
        => Assert.Equal(tier, League.StartingLevel(sport, volume, vices));

    [Theory]
    [InlineData(ActivityType.Run, -1, 0)]
    [InlineData(ActivityType.Run, 100.5, 0)]
    [InlineData(ActivityType.Cycle, 301, 0)]
    [InlineData(ActivityType.Swim, 3001, 0)]
    [InlineData(ActivityType.Run, double.NaN, 0)]
    [InlineData(ActivityType.Run, 10, -1)]
    [InlineData(ActivityType.Run, 10, 41)]
    [InlineData((ActivityType)99, 10, 0)]
    public void Answers_out_of_range_are_refused(ActivityType sport, double volume, int vices)
        => Assert.Throws<ValidationException>(() => Seeding.Validate(sport, volume, vices));

    [Fact]
    public void The_edges_of_the_ranges_are_accepted()
    {
        Seeding.Validate(ActivityType.Run, 0, 0);
        Seeding.Validate(ActivityType.Run, 100, 40);
        Seeding.Validate(ActivityType.Cycle, 300, 40);
        Seeding.Validate(ActivityType.Swim, 3000, 40);
    }

    [Theory]
    [InlineData("🎮", "🎮")]
    [InlineData("  🎮  ", "🎮")]
    [InlineData("☕", "☕")]
    [InlineData("🍕🍩", "🍕🍩")] // two characters, each a surrogate pair
    [InlineData("", "🍕")]
    [InlineData("   ", "🍕")]
    [InlineData(null, "🍕")]
    public void A_vice_is_trimmed_and_empty_falls_back_to_pizza(string? input, string expected)
        => Assert.Equal(expected, ViceRules.Normalise(input));

    [Theory]
    [InlineData("a")]
    [InlineData("🎮a")]
    [InlineData("beer")]
    [InlineData("🍕🍩🍫")]
    [InlineData("1")]
    public void Plain_text_and_too_many_characters_are_refused(string input)
        => Assert.Throws<ValidationException>(() => ViceRules.Normalise(input));
}
