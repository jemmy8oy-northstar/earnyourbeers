using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>"Run", "Cycle" or "Swim"; volume in km (Run, Cycle) or lengths (Swim); at most 40 vices a week.</summary>
public record OnboardRequest(ActivityType Sport, double WeeklyVolume, string? ViceEmoji, double WeeklyViceCount);
