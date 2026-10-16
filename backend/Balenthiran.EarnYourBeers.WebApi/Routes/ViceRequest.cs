namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>The new vice: at most 2 characters, no plain text; empty means the pizza.</summary>
public record ViceRequest(string? ViceEmoji);
