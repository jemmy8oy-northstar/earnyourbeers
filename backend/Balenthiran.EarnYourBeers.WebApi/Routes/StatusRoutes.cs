using Balenthiran.EarnYourBeers.Abstractions.DataModels;
using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Services;

namespace Balenthiran.EarnYourBeers.WebApi.Routes;

public static class StatusRoutes
{
    public static RouteGroupBuilder MapStatusRoutes(this RouteGroupBuilder parentGroup)
    {
        var group = parentGroup.MapGroup("/status");

        group.MapGet("", async (IStatusService statusService) =>
        {
            var status = await statusService.GetSystemStatusAsync();
            return Results.Ok(new {
                version = status.Version,
                friendlyStatus = status.GetFriendlyStatus(),
                timestamp = status.LastUpdated
            });
        })
        .WithName("GetStatus");

        return parentGroup;
    }
}
