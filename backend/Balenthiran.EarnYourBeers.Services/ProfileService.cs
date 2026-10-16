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
/// BEH-SETTLE-1/2, ported from lib/core/logic/app_state.dart:328-410. The phone app settled on
/// launch; the web settles on the first dashboard request of a new week (an assumption in the spec).
/// </summary>
public class ProfileService(AppDbContext db, ILogService log, ILeague league, TimeProvider clock) : IProfileService
{
    public const string DefaultVice = "🍕";

    public async Task<IProfile> GetAndSettleAsync(string userId, CancellationToken ct = default)
    {
        var p = await LoadAsync(userId, ct);
        var now = clock.GetUtcNow().UtcDateTime;

        if (p.LastSettledAt is not { } last)
        {
            p.LastSettledAt = now;
        }
        else
        {
            var from = log.WeekStart(last);
            var to = log.WeekStart(now);
            if (to > from)
            {
                var weeklyNet = await log.BalanceAsync(userId, from, to, p.Level, ct);
                var result = league.Settle(p.Level, p.Tally, weeklyNet);
                p.Level = result.Level;
                p.Tally = result.Tally;
                p.LastSettledAt = to;
                p.ReportPending = true;
                p.ReportWeeklyNet = weeklyNet;
                p.ReportOutcome = result.Outcome;
            }
        }

        await db.SaveChangesAsync(ct);
        return ToProfile(p);
    }

    public async Task DismissReportAsync(string userId, CancellationToken ct = default)
    {
        var p = await LoadAsync(userId, ct);
        p.ReportPending = false;
        await db.SaveChangesAsync(ct);
    }

    public async Task<IProfile> OnboardAsync(string userId, ActivityType sport, double weeklyVolume, string? viceEmoji, int weeklyViceCount, CancellationToken ct = default)
    {
        Seeding.Validate(sport, weeklyVolume, weeklyViceCount);
        var emoji = ViceRules.Normalise(viceEmoji);
        var p = await LoadAsync(userId, ct);
        if (p.OnboardedAt is not null)
        {
            throw new ConflictException("Already onboarded. Reset first to start again.");
        }

        var now = clock.GetUtcNow().UtcDateTime;
        p.Level = league.StartingLevel(sport, weeklyVolume, weeklyViceCount);
        p.Tally = 0;
        p.ViceEmoji = emoji;
        p.OnboardedAt = now;
        p.LastSettledAt = now;
        await db.SaveChangesAsync(ct);
        return ToProfile(p);
    }

    public async Task<IProfile> ChangeViceAsync(string userId, string? viceEmoji, CancellationToken ct = default)
    {
        var emoji = ViceRules.Normalise(viceEmoji);
        var p = await LoadAsync(userId, ct);
        p.ViceEmoji = emoji;
        await db.SaveChangesAsync(ct);
        return ToProfile(p);
    }

    public async Task ResetAsync(string userId, CancellationToken ct = default)
    {
        db.ActivityEntries.RemoveRange(await db.ActivityEntries.Where(a => a.UserId == userId).ToListAsync(ct));
        db.ViceEntries.RemoveRange(await db.ViceEntries.Where(v => v.UserId == userId).ToListAsync(ct));
        db.Profiles.RemoveRange(await db.Profiles.Where(x => x.UserId == userId).ToListAsync(ct));
        await db.SaveChangesAsync(ct);
    }

    private static Profile ToProfile(ProfileEntity p) => new(
        p.Level,
        p.Tally,
        p.ViceEmoji,
        p.OnboardedAt is not null,
        p.ReportPending ? new SettlementReport(p.ReportWeeklyNet, p.ReportOutcome) : null);

    private async Task<ProfileEntity> LoadAsync(string userId, CancellationToken ct)
    {
        var p = await db.Profiles.SingleOrDefaultAsync(x => x.UserId == userId, ct);
        if (p is null)
        {
            p = new ProfileEntity { UserId = userId, ViceEmoji = DefaultVice };
            db.Profiles.Add(p);
        }

        return p;
    }
}
