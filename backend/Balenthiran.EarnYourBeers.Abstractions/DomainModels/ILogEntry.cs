using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.Abstractions.DomainModels;

/// <summary>One logged activity or vice, as the dashboard lists it (BEH-HISTORY-1).</summary>
public interface ILogEntry
{
    Guid Id { get; }

    LogKind Kind { get; }

    /// <summary>The activity, or null for a vice.</summary>
    ActivityType? Activity { get; }

    double Amount { get; }

    DateTime LoggedAt { get; }
}
