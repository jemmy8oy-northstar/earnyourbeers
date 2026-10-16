using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.Abstractions.Services;

/// <summary>
/// One user's log (BEH-LOG-1..3, BEH-BALANCE-1, BEH-HISTORY-1): logging, the one-hour merge, editing
/// the newest entry, and a week's entries and balance. Every method is scoped to one user (BEH-AUTH-2).
/// </summary>
public interface ILogService
{
    /// <summary>
    /// Logs an activity. If the user's newest entry of all is the same activity and under an hour
    /// old, the amount is added to it instead (BEH-LOG-2). The amount must be above 0.
    /// </summary>
    Task<ILogEntry> LogActivityAsync(string userId, ActivityType type, double amount, CancellationToken ct = default);

    /// <summary>Logs vice units, merging into the newest entry when that is a vice under an hour old.</summary>
    Task<ILogEntry> LogViceAsync(string userId, double amount, CancellationToken ct = default);

    /// <summary>
    /// Sets the amount of the user's newest entry this week (BEH-LOG-3); 0 or more. Any other entry
    /// is refused, so history cannot be rewritten.
    /// </summary>
    Task<ILogEntry> EditNewestAsync(string userId, Guid entryId, double amount, CancellationToken ct = default);

    /// <summary>Deletes the user's newest entry this week (BEH-LOG-3); any other is refused.</summary>
    Task DeleteNewestAsync(string userId, Guid entryId, CancellationToken ct = default);

    /// <summary>The week (Monday 00:00 UTC) that contains <paramref name="at"/>.</summary>
    DateTime WeekStart(DateTime at);

    /// <summary>When the user's oldest entry was logged, or null with none — where history paging stops.</summary>
    Task<DateTime?> FirstLoggedAtAsync(string userId, CancellationToken ct = default);

    /// <summary>The user's entries in the week starting <paramref name="weekStart"/>, newest first.</summary>
    Task<IReadOnlyList<ILogEntry>> WeekAsync(string userId, DateTime weekStart, CancellationToken ct = default);

    /// <summary>
    /// Net points between two instants at a level (BEH-SCORE-2). A past week uses the level passed
    /// in, which the dashboard sets to today's (BEH-HISTORY-1).
    /// </summary>
    Task<double> BalanceAsync(string userId, DateTime from, DateTime to, int level, CancellationToken ct = default);
}
