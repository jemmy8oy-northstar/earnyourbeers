using Balenthiran.EarnYourBeers.Abstractions.DomainModels;

namespace Balenthiran.EarnYourBeers.Abstractions.Services;

/// <summary>A user's league state: reading it, settling finished weeks, and dismissing the report.</summary>
public interface IProfileService
{
    /// <summary>
    /// The profile, made on first use at tier 0 with 🍕. Before returning it settles any week that
    /// has finished since the last settlement (BEH-SETTLE-1): several missed weeks settle as one, at
    /// the level in force, and the very first visit records the date and settles nothing.
    /// </summary>
    Task<IProfile> GetAndSettleAsync(string userId, CancellationToken ct = default);

    /// <summary>Clears the pending settlement report (BEH-SETTLE-2's "start new week").</summary>
    Task DismissReportAsync(string userId, CancellationToken ct = default);
}
