namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>One log entry. <c>Activity</c> is "Run", "Cycle" or "Swim", or null for a vice.</summary>
public record EntryResponse(Guid Id, string Kind, string? Activity, double Amount, DateTime LoggedAt, bool Editable);
