namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>A clock a test sets and moves by hand.</summary>
public sealed class ManualClock(DateTimeOffset now) : TimeProvider
{
    public DateTimeOffset Now { get; set; } = now;

    public override DateTimeOffset GetUtcNow() => Now;

    /// <summary>
    /// Noon on the first Wednesday after today. A test that signs in over HTTP must start
    /// here, not at a fixed date: the session cookie expires 30 days after this clock, and
    /// the test client's cookie jar reads the real clock, so a date more than 30 days ago
    /// gets every signed-in request a 401.
    /// </summary>
    public static DateTimeOffset NextWednesdayNoon()
    {
        var today = DateTimeOffset.UtcNow.UtcDateTime.Date;
        var days = ((int)DayOfWeek.Wednesday - (int)today.DayOfWeek + 7) % 7;
        return new DateTimeOffset(today.AddDays(days == 0 ? 7 : days).AddHours(12), TimeSpan.Zero);
    }
}
