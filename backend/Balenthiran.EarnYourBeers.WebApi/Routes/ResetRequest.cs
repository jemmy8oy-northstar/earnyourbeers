namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>Resetting is destructive, so it has to say so: <c>{"confirm": true}</c>.</summary>
public record ResetRequest(bool Confirm);
