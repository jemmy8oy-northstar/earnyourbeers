using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.Abstractions.Services;

/// <summary>A user's league state: reading it, settling finished weeks, and dismissing the report.</summary>
public interface IProfileService
{
    /// <summary>
    /// The profile, made on first use at tier 0 with 🍺. Before returning it settles any week that
    /// has finished since the last settlement (BEH-SETTLE-1): several missed weeks settle as one, at
    /// the level in force, and the very first visit records the date and settles nothing.
    /// </summary>
    Task<IProfile> GetAndSettleAsync(string userId, CancellationToken ct = default);

    /// <summary>Clears the pending settlement report (BEH-SETTLE-2's "start new week").</summary>
    Task DismissReportAsync(string userId, CancellationToken ct = default);

    /// <summary>
    /// BEH-ONBOARD-1/2: validates the answers, seeds the starting tier from them, and marks the
    /// profile onboarded (tally 0, settled now). ValidationException on bad answers; ConflictException
    /// if already onboarded.
    /// </summary>
    Task<IProfile> OnboardAsync(string userId, ActivityType sport, double weeklyVolume, string? viceEmoji, int weeklyViceCount, CancellationToken ct = default);

    /// <summary>BEH-VICE-1: changes the vice; empty falls back to the pizza, plain text is refused.</summary>
    Task<IProfile> ChangeViceAsync(string userId, string? viceEmoji, CancellationToken ct = default);

    /// <summary>BEH-RESET-1: deletes the user's log entries and profile; the account stays and the next dashboard shows onboarding.</summary>
    Task ResetAsync(string userId, CancellationToken ct = default);
}
