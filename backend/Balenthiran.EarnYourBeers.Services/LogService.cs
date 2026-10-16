using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Exceptions;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.Database;
using Balenthiran.EarnYourBeers.DomainModels.Models;
using Balenthiran.EarnYourBeers.EntityModels;
using Microsoft.EntityFrameworkCore;

namespace Balenthiran.EarnYourBeers.Services;

/// <summary>
/// Persistence shell around <see cref="IScoring"/> for one user's log. The merge and edit rules are
/// ported from lib/core/logic/app_state.dart:486-518 and dashboard_screen.dart:368, 463-469.
/// </summary>
/// <remarks>
/// Weeks are Monday 00:00 UTC. The Flutter app used the phone's local time; the web has no phone,
/// so this is an assumption written into the spec, not a port.
/// </remarks>
public class LogService(AppDbContext db, IScoring scoring, TimeProvider clock) : ILogService
{
    private static readonly TimeSpan MergeWindow = TimeSpan.FromHours(1);

    public async Task<ILogEntry> LogActivityAsync(string userId, ActivityType type, double amount, CancellationToken ct = default)
    {
        RequireAboveZero(amount);
        var now = Now();
        var newest = await NewestAsync(userId, ct);
        if (newest is { Kind: LogKind.Activity } n && n.Activity == type && now - n.LoggedAt < MergeWindow)
        {
            var row = await db.ActivityEntries.SingleAsync(a => a.Id == n.Id, ct);
            row.Amount += amount;
            await db.SaveChangesAsync(ct);
            return ToEntry(row);
        }

        var added = new ActivityEntryEntity { Id = Guid.NewGuid(), UserId = userId, Type = type, Amount = amount, LoggedAt = now };
        db.ActivityEntries.Add(added);
        await db.SaveChangesAsync(ct);
        return ToEntry(added);
    }

    public async Task<ILogEntry> LogViceAsync(string userId, double amount, CancellationToken ct = default)
    {
        RequireAboveZero(amount);
        var now = Now();
        var newest = await NewestAsync(userId, ct);
        if (newest is { Kind: LogKind.Vice } n && now - n.LoggedAt < MergeWindow)
        {
            var row = await db.ViceEntries.SingleAsync(v => v.Id == n.Id, ct);
            row.Amount += amount;
            await db.SaveChangesAsync(ct);
            return ToEntry(row);
        }

        var added = new ViceEntryEntity { Id = Guid.NewGuid(), UserId = userId, Amount = amount, LoggedAt = now };
        db.ViceEntries.Add(added);
        await db.SaveChangesAsync(ct);
        return ToEntry(added);
    }

    public async Task<ILogEntry> EditNewestAsync(string userId, Guid entryId, double amount, CancellationToken ct = default)
    {
        if (!double.IsFinite(amount) || amount < 0)
        {
            throw new ValidationException("An amount must be 0 or more.");
        }

        var newest = await NewestThisWeekAsync(userId, entryId, ct);
        if (newest.Kind == LogKind.Activity)
        {
            var row = await db.ActivityEntries.SingleAsync(a => a.Id == entryId, ct);
            row.Amount = amount;
            await db.SaveChangesAsync(ct);
            return ToEntry(row);
        }

        var vice = await db.ViceEntries.SingleAsync(v => v.Id == entryId, ct);
        vice.Amount = amount;
        await db.SaveChangesAsync(ct);
        return ToEntry(vice);
    }

    public async Task DeleteNewestAsync(string userId, Guid entryId, CancellationToken ct = default)
    {
        var newest = await NewestThisWeekAsync(userId, entryId, ct);
        if (newest.Kind == LogKind.Activity)
        {
            db.ActivityEntries.Remove(await db.ActivityEntries.SingleAsync(a => a.Id == entryId, ct));
        }
        else
        {
            db.ViceEntries.Remove(await db.ViceEntries.SingleAsync(v => v.Id == entryId, ct));
        }

        await db.SaveChangesAsync(ct);
    }

    public DateTime WeekStart(DateTime at)
    {
        var day = DateTime.SpecifyKind(at.Date, DateTimeKind.Utc);
        var sinceMonday = ((int)day.DayOfWeek + 6) % 7;
        return day.AddDays(-sinceMonday);
    }

    public async Task<IReadOnlyList<ILogEntry>> WeekAsync(string userId, DateTime weekStart, CancellationToken ct = default)
        => (await EntriesAsync(userId, weekStart, weekStart.AddDays(7), ct))
            .OrderByDescending(e => e.LoggedAt)
            .ToList();

    public async Task<double> BalanceAsync(string userId, DateTime from, DateTime to, int level, CancellationToken ct = default)
    {
        var entries = await EntriesAsync(userId, from, to, ct);
        var activityPoints = entries
            .Where(e => e.Kind == LogKind.Activity)
            .Sum(e => e.Amount * scoring.PointsPerUnit(e.Activity!.Value));
        var viceUnits = entries.Where(e => e.Kind == LogKind.Vice).Sum(e => e.Amount);
        return scoring.Balance(activityPoints, viceUnits, level);
    }

    private static void RequireAboveZero(double amount)
    {
        if (!double.IsFinite(amount) || amount <= 0)
        {
            throw new ValidationException("An amount must be above 0.");
        }
    }

    private static LogEntry ToEntry(ActivityEntryEntity a) => new(a.Id, LogKind.Activity, a.Type, a.Amount, a.LoggedAt);

    private static LogEntry ToEntry(ViceEntryEntity v) => new(v.Id, LogKind.Vice, null, v.Amount, v.LoggedAt);

    private DateTime Now() => clock.GetUtcNow().UtcDateTime;

    private async Task<ILogEntry> NewestThisWeekAsync(string userId, Guid entryId, CancellationToken ct)
    {
        var newest = await NewestAsync(userId, ct);
        if (newest is null || newest.Id != entryId || newest.LoggedAt < WeekStart(Now()))
        {
            throw new ConflictException("Only the newest entry this week can be changed.");
        }

        return newest;
    }

    private async Task<ILogEntry?> NewestAsync(string userId, CancellationToken ct)
    {
        var activity = await db.ActivityEntries.Where(a => a.UserId == userId).OrderByDescending(a => a.LoggedAt).FirstOrDefaultAsync(ct);
        var vice = await db.ViceEntries.Where(v => v.UserId == userId).OrderByDescending(v => v.LoggedAt).FirstOrDefaultAsync(ct);
        return (activity, vice) switch
        {
            (null, null) => null,
            (not null, null) => ToEntry(activity),
            (null, not null) => ToEntry(vice),
            _ => activity!.LoggedAt >= vice!.LoggedAt ? ToEntry(activity) : ToEntry(vice),
        };
    }

    private async Task<List<ILogEntry>> EntriesAsync(string userId, DateTime from, DateTime to, CancellationToken ct)
    {
        var activities = await db.ActivityEntries
            .Where(a => a.UserId == userId && a.LoggedAt >= from && a.LoggedAt < to)
            .ToListAsync(ct);
        var vices = await db.ViceEntries
            .Where(v => v.UserId == userId && v.LoggedAt >= from && v.LoggedAt < to)
            .ToListAsync(ct);
        return [.. activities.Select(ToEntry), .. vices.Select(ToEntry)];
    }
}
