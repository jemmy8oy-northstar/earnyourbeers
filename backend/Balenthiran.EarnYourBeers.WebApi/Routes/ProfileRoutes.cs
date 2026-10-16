using System.Security.Claims;
using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Exceptions;
using Balenthiran.EarnYourBeers.Abstractions.Services;

namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>
/// Onboarding, the vice setting and reset (BEH-ONBOARD-1/2, BEH-VICE-1, BEH-RESET-1), for the
/// signed-in user only; the user id comes from the cookie, never from the request.
/// </summary>
public static class ProfileRoutes
{
    public static RouteGroupBuilder MapProfileRoutes(this RouteGroupBuilder parentGroup)
    {
        var group = parentGroup.MapGroup("/profile").RequireAuthorization();

        group.MapPost("/onboard", async (OnboardRequest body, ClaimsPrincipal user, IProfileService profiles) =>
            Results.Ok(ToResponse(await profiles.OnboardAsync(Me(user), body.Sport, body.WeeklyVolume, body.ViceEmoji, body.WeeklyViceCount))))
        .WithName("Onboard");

        group.MapPut("/vice", async (ViceRequest body, ClaimsPrincipal user, IProfileService profiles) =>
            Results.Ok(ToResponse(await profiles.ChangeViceAsync(Me(user), body.ViceEmoji))))
        .WithName("ChangeVice");

        group.MapPost("/reset", async (ResetRequest body, ClaimsPrincipal user, IProfileService profiles) =>
        {
            if (!body.Confirm)
            {
                throw new ValidationException("Resetting deletes every log entry; send {\"confirm\": true}.");
            }

            await profiles.ResetAsync(Me(user));
            return Results.NoContent();
        })
        .WithName("ResetProfile");

        return parentGroup;
    }

    private static string Me(ClaimsPrincipal user) => AuthRoutes.UserId(user)!.Value.ToString();

    private static ProfileResponse ToResponse(IProfile p) => new(p.Onboarded, p.Level, p.Tally, p.ViceEmoji);
}
