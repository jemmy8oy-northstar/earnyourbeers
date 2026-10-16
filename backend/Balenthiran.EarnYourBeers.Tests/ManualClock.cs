namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>A clock a test sets and moves by hand.</summary>
public sealed class ManualClock(DateTimeOffset now) : TimeProvider
{
    public DateTimeOffset Now { get; set; } = now;

    public override DateTimeOffset GetUtcNow() => Now;
}
