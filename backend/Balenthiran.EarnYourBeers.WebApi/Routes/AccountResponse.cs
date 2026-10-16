namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>Who is signed in. Only the username: the id stays in the cookie.</summary>
public record AccountResponse(string Username);
