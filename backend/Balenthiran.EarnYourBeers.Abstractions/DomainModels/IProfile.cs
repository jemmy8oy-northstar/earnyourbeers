namespace Balenthiran.EarnYourBeers.Abstractions.DomainModels;

/// <summary>A user's league state and settings, as the dashboard shows them.</summary>
public interface IProfile
{
    int Level { get; }

    double Tally { get; }

    string ViceEmoji { get; }

    bool Onboarded { get; }

    /// <summary>The settlement report still to be dismissed, or null (BEH-SETTLE-2).</summary>
    ISettlementReport? PendingReport { get; }
}
