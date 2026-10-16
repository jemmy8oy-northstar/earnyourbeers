using System.Security.Claims;
using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>BEH-AUTH-1: sign up, sign in, sign out, and who am I. A session is an HTTP-only cookie.</summary>
public static class AuthRoutes
{
    public static RouteGroupBuilder MapAuthRoutes(this RouteGroupBuilder parentGroup)
    {
        var group = parentGroup.MapGroup("/auth");

        group.MapPost("/register", async (Credentials body, IAccountService accounts, HttpContext http) =>
        {
            var account = await accounts.RegisterAsync(body.Username, body.Password);
            await SignInAsync(http, account);
            return Results.Created("/api/auth/me", new AccountResponse(account.Username));
        })
        .WithName("Register");

        group.MapPost("/login", async (Credentials body, IAccountService accounts, HttpContext http) =>
        {
            var account = await accounts.SignInAsync(body.Username, body.Password);
            await SignInAsync(http, account);
            return Results.Ok(new AccountResponse(account.Username));
        })
        .WithName("Login");

        group.MapPost("/logout", async (HttpContext http) =>
        {
            await http.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return Results.NoContent();
        })
        .WithName("Logout");

        group.MapGet("/me", async (ClaimsPrincipal user, IAccountService accounts) =>
            UserId(user) is { } id && await accounts.FindAsync(id) is { } account
                ? Results.Ok(new AccountResponse(account.Username))
                : Results.Unauthorized())
        .WithName("Me");

        return parentGroup;
    }

    /// <summary>The signed-in account's id, or null for no session or one whose claim is not an id.</summary>
    public static Guid? UserId(ClaimsPrincipal user)
        => Guid.TryParse(user.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : null;

    private static Task SignInAsync(HttpContext http, IAccount account)
    {
        var identity = new ClaimsIdentity(
            [new Claim(ClaimTypes.NameIdentifier, account.Id.ToString()), new Claim(ClaimTypes.Name, account.Username)],
            CookieAuthenticationDefaults.AuthenticationScheme);
        return http.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(identity), new AuthenticationProperties { IsPersistent = true });
    }
}
