using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.EntityModels;

/// <summary>
/// One user's league state and settings (BEH-LEAGUE-1, BEH-SETTLE-1/2, BEH-VICE-1): what the Flutter
/// app kept in its key/value Settings table, one row per user.
/// </summary>
public class ProfileEntity
{
    public required string UserId { get; set; }

    public int Level { get; set; }

    public double Tally { get; set; }

    /// <summary>When the last week was settled; null until the first dashboard visit records it.</summary>
    public DateTime? LastSettledAt { get; set; }

    public required string ViceEmoji { get; set; }

    public DateTime? OnboardedAt { get; set; }

    /// <summary>The last settlement's report, kept until it is dismissed (BEH-SETTLE-2).</summary>
    public bool ReportPending { get; set; }

    public double ReportWeeklyNet { get; set; }

    public SettlementOutcome ReportOutcome { get; set; }
}
