using System.Security.Claims;
using Balenthiran.EarnYourBeers.Abstractions.Enums;
using Balenthiran.EarnYourBeers.Abstractions.Services;

namespace Balenthiran.EarnYourBeers.WebApi.Routes;

/// <summary>
/// The dashboard and the log, for the signed-in user only (BEH-AUTH-2). Every route needs a session;
/// the user id comes from the cookie, never from the request.
/// </summary>
public static class DashboardRoutes
{
    public static RouteGroupBuilder MapDashboardRoutes(this RouteGroupBuilder parentGroup)
    {
        var group = parentGroup.MapGroup("").RequireAuthorization();

        group.MapGet("/dashboard", async (int? week, ClaimsPrincipal user, IProfileService profiles, ILogService log, ILeague league, IScoring scoring, TimeProvider clock) =>
        {
            var id = Me(user);
            var profile = await profiles.GetAndSettleAsync(id);
            var offset = Math.Min(week ?? 0, 0);
            var thisWeek = log.WeekStart(clock.GetUtcNow().UtcDateTime);
            var start = thisWeek.AddDays(7 * offset);
            var entries = await log.WeekAsync(id, start);
            var balance = await log.BalanceAsync(id, start, start.AddDays(7), profile.Level);
            var first = await log.FirstLoggedAtAsync(id);
            var tier = league.Tiers[Math.Clamp(profile.Level, 0, league.Tiers.Count - 1)];
            var difficulty = scoring.Difficulty(profile.Level);

            // BEH-LOG-3: only the newest entry of all, and only while its week is this week.
            var newest = offset == 0 ? entries.FirstOrDefault()?.Id : null;

            return Results.Ok(new DashboardResponse(
                profile.Onboarded,
                profile.ViceEmoji,
                new LeagueResponse(profile.Level, tier.Name, tier.Division, profile.Tally, league.TallyProgress(profile.Tally), difficulty),
                Enum.GetValues<ActivityType>().ToDictionary(t => t.ToString(), t => scoring.PointsPerUnit(t) * difficulty),
                new WeekResponse(
                    offset,
                    start,
                    balance,
                    entries.Select(e => new EntryResponse(e.Id, e.Kind.ToString(), e.Activity?.ToString(), e.Amount, e.LoggedAt, e.Id == newest)).ToList(),
                    first is { } f && f < start),
                profile.PendingReport is { } r ? new SettlementResponse(r.WeeklyNet, r.Outcome.ToString()) : null));
        })
        .WithName("GetDashboard");

        group.MapPost("/settlement/dismiss", async (ClaimsPrincipal user, IProfileService profiles) =>
        {
            await profiles.DismissReportAsync(Me(user));
            return Results.NoContent();
        })
        .WithName("DismissSettlement");

        group.MapPost("/log/activity", async (ActivityRequest body, ClaimsPrincipal user, ILogService log) =>
            Results.Ok(ToResponse(await log.LogActivityAsync(Me(user), body.Type, body.Amount))))
        .WithName("LogActivity");

        group.MapPost("/log/vice", async (AmountRequest body, ClaimsPrincipal user, ILogService log) =>
            Results.Ok(ToResponse(await log.LogViceAsync(Me(user), body.Amount))))
        .WithName("LogVice");

        group.MapPut("/log/{id:guid}", async (Guid id, AmountRequest body, ClaimsPrincipal user, ILogService log) =>
            Results.Ok(ToResponse(await log.EditNewestAsync(Me(user), id, body.Amount))))
        .WithName("EditEntry");

        group.MapDelete("/log/{id:guid}", async (Guid id, ClaimsPrincipal user, ILogService log) =>
        {
            await log.DeleteNewestAsync(Me(user), id);
            return Results.NoContent();
        })
        .WithName("DeleteEntry");

        return parentGroup;
    }

    // RequireAuthorization has already refused a request without a valid session.
    private static string Me(ClaimsPrincipal user) => AuthRoutes.UserId(user)!.Value.ToString();

    private static EntryResponse ToResponse(Abstractions.DomainModels.ILogEntry e)
        => new(e.Id, e.Kind.ToString(), e.Activity?.ToString(), e.Amount, e.LoggedAt, true);
}
