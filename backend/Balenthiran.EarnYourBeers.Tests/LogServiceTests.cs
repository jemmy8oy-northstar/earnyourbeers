using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Exceptions;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.Database;
using Balenthiran.EarnYourBeers.Services;
using Microsoft.EntityFrameworkCore;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>
/// BEH-LOG-1..3, BEH-BALANCE-1, BEH-HISTORY-1 and BEH-AUTH-2's data half, against EF's in-memory
/// provider. The rules are the Flutter app's (app_state.dart:486-518, dashboard_screen.dart:368).
/// </summary>
public class LogServiceTests
{
    // A Wednesday, so "this week" started two days earlier.
    private static readonly DateTimeOffset Wednesday = new(2026, 10, 14, 12, 0, 0, TimeSpan.Zero);

    // Taps are a minute apart unless a test says otherwise: two entries never share an instant.
    private readonly Clock _clock = new(Wednesday);
    private readonly AppDbContext _db = new(new DbContextOptionsBuilder<AppDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);
    private readonly ILogService _log;

    public LogServiceTests() => _log = new LogService(_db, new Scoring(), _clock);

    private sealed class Clock(DateTimeOffset now) : TimeProvider
    {
        public DateTimeOffset Now { get; set; } = now;

        public override DateTimeOffset GetUtcNow() => Now;
    }

    // ---- BEH-LOG-2: the one-hour merge ----

    [Fact]
    public async Task A_repeat_tap_within_the_hour_adds_to_the_newest_entry()
    {
        var first = await _log.LogActivityAsync("u", ActivityType.Run, 1);
        _clock.Now += TimeSpan.FromMinutes(59);
        var second = await _log.LogActivityAsync("u", ActivityType.Run, 1);

        Assert.Equal(first.Id, second.Id);
        Assert.Equal(2, second.Amount);
        Assert.Single(await _log.WeekAsync("u", _log.WeekStart(Wednesday.UtcDateTime)));
    }

    [Fact]
    public async Task An_hour_later_it_is_a_new_entry()
    {
        await _log.LogActivityAsync("u", ActivityType.Run, 1);
        _clock.Now += TimeSpan.FromHours(1);
        await _log.LogActivityAsync("u", ActivityType.Run, 1);

        Assert.Equal(2, (await _log.WeekAsync("u", _log.WeekStart(Wednesday.UtcDateTime))).Count);
    }

    [Fact]
    public async Task Only_the_newest_entry_of_all_is_merged_into()
    {
        // Run, then a vice, then Run again: the newest is the vice, so the second run is new.
        await _log.LogActivityAsync("u", ActivityType.Run, 1);
        _clock.Now += TimeSpan.FromMinutes(1);
        await _log.LogViceAsync("u", 1);
        _clock.Now += TimeSpan.FromMinutes(1);
        await _log.LogActivityAsync("u", ActivityType.Run, 1);
        _clock.Now += TimeSpan.FromMinutes(1);
        await _log.LogViceAsync("u", 2);
        _clock.Now += TimeSpan.FromMinutes(1);
        await _log.LogViceAsync("u", 3);

        var week = await _log.WeekAsync("u", _log.WeekStart(Wednesday.UtcDateTime));
        Assert.Equal(4, week.Count);
        Assert.Equal(5, week.Single(e => e.Kind == LogKind.Vice && e.Amount > 1).Amount);
    }

    [Fact]
    public async Task A_different_activity_is_a_new_entry()
    {
        await _log.LogActivityAsync("u", ActivityType.Run, 1);
        await _log.LogActivityAsync("u", ActivityType.Swim, 1);

        Assert.Equal(2, (await _log.WeekAsync("u", _log.WeekStart(Wednesday.UtcDateTime))).Count);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    [InlineData(double.NaN)]
    public async Task A_logged_amount_must_be_above_zero(double amount)
    {
        await Assert.ThrowsAsync<ValidationException>(() => _log.LogViceAsync("u", amount));
        await Assert.ThrowsAsync<ValidationException>(() => _log.LogActivityAsync("u", ActivityType.Cycle, amount));
    }

    // ---- BEH-LOG-3: only the newest entry this week can change ----

    [Fact]
    public async Task The_newest_entry_can_be_edited_to_zero_or_more()
    {
        var e = await _log.LogViceAsync("u", 3);

        Assert.Equal(0, (await _log.EditNewestAsync("u", e.Id, 0)).Amount);
        await Assert.ThrowsAsync<ValidationException>(() => _log.EditNewestAsync("u", e.Id, -1));
    }

    [Fact]
    public async Task An_older_entry_cannot_be_edited_or_deleted()
    {
        var older = await _log.LogActivityAsync("u", ActivityType.Run, 5);
        _clock.Now += TimeSpan.FromMinutes(1);
        await _log.LogViceAsync("u", 1);

        await Assert.ThrowsAsync<ConflictException>(() => _log.EditNewestAsync("u", older.Id, 1));
        await Assert.ThrowsAsync<ConflictException>(() => _log.DeleteNewestAsync("u", older.Id));
    }

    [Fact]
    public async Task Last_weeks_newest_entry_is_history_and_cannot_change()
    {
        var e = await _log.LogViceAsync("u", 1);
        _clock.Now += TimeSpan.FromDays(7);

        await Assert.ThrowsAsync<ConflictException>(() => _log.DeleteNewestAsync("u", e.Id));
    }

    [Fact]
    public async Task Deleting_the_newest_makes_the_one_before_it_newest()
    {
        var older = await _log.LogActivityAsync("u", ActivityType.Run, 5);
        _clock.Now += TimeSpan.FromMinutes(1);
        var newer = await _log.LogViceAsync("u", 1);

        await _log.DeleteNewestAsync("u", newer.Id);
        await _log.DeleteNewestAsync("u", older.Id);

        Assert.Empty(await _log.WeekAsync("u", _log.WeekStart(Wednesday.UtcDateTime)));
    }

    // ---- BEH-AUTH-2: one user's rows only ----

    [Fact]
    public async Task Another_users_entries_are_neither_listed_nor_merged_nor_changeable()
    {
        var theirs = await _log.LogViceAsync("them", 4);
        var mine = await _log.LogViceAsync("me", 1);

        Assert.NotEqual(theirs.Id, mine.Id);
        Assert.Equal([mine.Id], (await _log.WeekAsync("me", _log.WeekStart(Wednesday.UtcDateTime))).Select(e => e.Id));
        await Assert.ThrowsAsync<ConflictException>(() => _log.DeleteNewestAsync("me", theirs.Id));
        Assert.Equal(-1, await _log.BalanceAsync("me", DateTime.MinValue, DateTime.MaxValue, 10), 9);
    }

    // ---- BEH-BALANCE-1 / BEH-HISTORY-1: weeks and balances ----

    [Theory]
    [InlineData("2026-10-12T00:00:00Z", "2026-10-12")] // Monday midnight is the start of its own week
    [InlineData("2026-10-14T12:00:00Z", "2026-10-12")]
    [InlineData("2026-10-18T23:59:59Z", "2026-10-12")] // Sunday night is still the same week
    [InlineData("2026-10-19T00:00:00Z", "2026-10-19")]
    public void A_week_runs_Monday_to_Monday(string at, string monday)
        => Assert.Equal(DateTime.Parse(monday + "T00:00:00Z").ToUniversalTime(), _log.WeekStart(DateTime.Parse(at).ToUniversalTime()));

    [Fact]
    public async Task A_weeks_balance_counts_that_week_only_newest_first()
    {
        _clock.Now = Wednesday - TimeSpan.FromDays(7);
        await _log.LogViceAsync("u", 9); // last week
        _clock.Now = Wednesday;
        await _log.LogActivityAsync("u", ActivityType.Run, 10); // 5 raw points
        _clock.Now += TimeSpan.FromHours(2);
        await _log.LogViceAsync("u", 3);

        var monday = _log.WeekStart(Wednesday.UtcDateTime);
        var week = await _log.WeekAsync("u", monday);

        Assert.Equal([LogKind.Vice, LogKind.Activity], week.Select(e => e.Kind));
        Assert.Equal(2.0, await _log.BalanceAsync("u", monday, monday.AddDays(7), 10), 3); // 5 × 1.0 − 3
        Assert.Equal(47.0, await _log.BalanceAsync("u", monday, monday.AddDays(7), 0), 9); // 5 × 10 − 3
    }
}
