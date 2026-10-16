namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>The banner (BEH-LEAGUE-1): tier, division, tally and the bar's fill, plus today's multiplier.</summary>
public record LeagueResponse(int Level, string Tier, string Division, double Tally, double TallyProgress, double Difficulty);
