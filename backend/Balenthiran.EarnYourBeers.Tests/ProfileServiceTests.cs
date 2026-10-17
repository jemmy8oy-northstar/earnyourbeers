using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.Database;
using Balenthiran.EarnYourBeers.Services;
using Microsoft.EntityFrameworkCore;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>BEH-SETTLE-1/2: a finished week settles once, on the first visit after it, and its report waits to be dismissed.</summary>
public class ProfileServiceTests
{
    private static readonly DateTimeOffset Wednesday = new(2026, 10, 14, 12, 0, 0, TimeSpan.Zero);

    private readonly ManualClock _clock = new(Wednesday);
    private readonly ILogService _log;
    private readonly IProfileService _profiles;

    public ProfileServiceTests()
    {
        var db = new AppDbContext(new DbContextOptionsBuilder<AppDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);
        var scoring = new Scoring();
        _log = new LogService(db, scoring, _clock);
        _profiles = new ProfileService(db, _log, new League(scoring), _clock);
    }

    [Fact]
    public async Task A_new_profile_starts_at_tier_zero_with_pizza_and_settles_nothing()
    {
        var p = await _profiles.GetAndSettleAsync("u");

        Assert.Equal(0, p.Level);
        Assert.Equal(0, p.Tally);
        Assert.Equal("🍺", p.ViceEmoji);
        Assert.False(p.Onboarded);
        Assert.Null(p.PendingReport);
    }

    [Fact]
    public async Task The_first_visit_of_a_new_week_settles_the_last_one()
    {
        await _profiles.GetAndSettleAsync("u"); // records Wednesday
        await _log.LogActivityAsync("u", ActivityType.Run, 5); // 2.5 raw × 10 at tier 0 = 25 points

        _clock.Now = Wednesday.AddDays(5); // the next Monday
        var p = await _profiles.GetAndSettleAsync("u");

        Assert.Equal(1, p.Level);
        Assert.Equal(0, p.Tally, 9);
        Assert.Equal(SettlementOutcome.Promoted, p.PendingReport!.Outcome);
        Assert.Equal(25, p.PendingReport.WeeklyNet, 9);
    }

    [Fact]
    public async Task A_week_settles_once_however_often_it_is_visited()
    {
        await _profiles.GetAndSettleAsync("u");
        await _log.LogViceAsync("u", 10);
        _clock.Now = Wednesday.AddDays(6);

        await _profiles.GetAndSettleAsync("u");
        var again = await _profiles.GetAndSettleAsync("u");

        Assert.Equal(-10, again.Tally, 9);
        Assert.Equal(SettlementOutcome.PositionSecured, again.PendingReport!.Outcome);
    }

    [Fact]
    public async Task The_report_stays_until_it_is_dismissed()
    {
        await _profiles.GetAndSettleAsync("u");
        _clock.Now = Wednesday.AddDays(7);
        Assert.NotNull((await _profiles.GetAndSettleAsync("u")).PendingReport);
        Assert.NotNull((await _profiles.GetAndSettleAsync("u")).PendingReport);

        await _profiles.DismissReportAsync("u");

        Assert.Null((await _profiles.GetAndSettleAsync("u")).PendingReport);
    }

    [Fact]
    public async Task Several_missed_weeks_settle_as_one()
    {
        await _profiles.GetAndSettleAsync("u");
        await _log.LogViceAsync("u", 20);
        _clock.Now = Wednesday.AddDays(7);
        await _log.LogViceAsync("u", 10);

        _clock.Now = Wednesday.AddDays(21); // three Mondays later, one visit
        var p = await _profiles.GetAndSettleAsync("u");

        Assert.Equal(-30, p.PendingReport!.WeeklyNet, 9);
        Assert.Equal(SettlementOutcome.Demoted, p.PendingReport.Outcome);
        Assert.Equal(0, p.Level); // clamped at the bottom
        Assert.Equal(-5, p.Tally, 9);
    }

    [Fact]
    public async Task This_weeks_entries_wait_for_next_Monday()
    {
        await _profiles.GetAndSettleAsync("u");
        _clock.Now = Wednesday.AddDays(5);
        await _profiles.GetAndSettleAsync("u"); // settles last week, which was empty
        await _profiles.DismissReportAsync("u");
        await _log.LogViceAsync("u", 30);

        var p = await _profiles.GetAndSettleAsync("u");

        Assert.Equal(0, p.Tally, 9);
        Assert.Null(p.PendingReport);
    }
}
