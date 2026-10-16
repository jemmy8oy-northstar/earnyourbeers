using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>An activity to log: "Run" or "Cycle" in km, "Swim" in lengths.</summary>
public record ActivityRequest(ActivityType Type, double Amount);
