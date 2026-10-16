namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>One week's entries, newest first, and its balance at today's level (BEH-HISTORY-1).</summary>
/// <param name="Offset">0 for this week, −1 for last week, and so on.</param>
/// <param name="HasEarlier">Whether an older week holds entries, so the client knows to offer "back".</param>
public record WeekResponse(int Offset, DateTime Start, double Balance, IReadOnlyList<EntryResponse> Entries, bool HasEarlier);
