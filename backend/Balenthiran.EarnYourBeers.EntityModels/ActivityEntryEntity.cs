using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.EntityModels;

/// <summary>A logged activity (BEH-LOG-1): km for Run and Cycle, lengths for Swim. One user's row.</summary>
public class ActivityEntryEntity
{
    public Guid Id { get; set; }

    public required string UserId { get; set; }

    public ActivityType Type { get; set; }

    public double Amount { get; set; }

    public DateTime LoggedAt { get; set; }
}
