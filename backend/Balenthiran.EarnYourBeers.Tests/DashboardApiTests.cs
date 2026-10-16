using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>The dashboard and log routes over HTTP, for a signed-in user (BEH-LOG-1, BEH-BALANCE-1, BEH-AUTH-2).</summary>
public class DashboardApiTests
{
    private static readonly DateTimeOffset Wednesday = new(2026, 10, 14, 12, 0, 0, TimeSpan.Zero);

    private static async Task<HttpClient> SignedUp(AppApiFactory factory, string username)
    {
        var client = factory.CreateClient();
        (await client.PostAsJsonAsync("/api/auth/register", new { username, password = "correct horse" })).EnsureSuccessStatusCode();
        return client;
    }

    [Theory]
    [InlineData("GET", "/api/dashboard")]
    [InlineData("POST", "/api/log/vice")]
    [InlineData("POST", "/api/settlement/dismiss")]
    public async Task Without_a_session_every_route_is_401(string method, string path)
    {
        using var factory = new AppApiFactory();
        var r = await factory.CreateClient().SendAsync(new HttpRequestMessage(new HttpMethod(method), path) { Content = JsonContent.Create(new { amount = 1 }) });

        Assert.Equal(HttpStatusCode.Unauthorized, r.StatusCode);
    }

    [Fact]
    public async Task Logging_shows_on_the_dashboard_with_the_balance_at_your_tier()
    {
        var clock = new ManualClock(Wednesday);
        using var factory = new AppApiFactory(clock);
        var client = await SignedUp(factory, "james");

        (await client.PostAsJsonAsync("/api/log/activity", new { type = "Run", amount = 10 })).EnsureSuccessStatusCode();
        clock.Now += TimeSpan.FromMinutes(1);
        (await client.PostAsJsonAsync("/api/log/vice", new { amount = 3 })).EnsureSuccessStatusCode();

        var d = await client.GetFromJsonAsync<JsonElement>("/api/dashboard");

        Assert.Equal(47, d.GetProperty("week").GetProperty("balance").GetDouble(), 9); // 10 km × 0.5 × 10 − 3
        Assert.Equal(5, d.GetProperty("pointsPerUnit").GetProperty("Run").GetDouble(), 9);
        Assert.Equal("Noob", d.GetProperty("league").GetProperty("tier").GetString());
        Assert.Equal("🍕", d.GetProperty("viceEmoji").GetString());
        var entries = d.GetProperty("week").GetProperty("entries").EnumerateArray().ToList();
        Assert.Equal(["Vice", "Activity"], entries.Select(e => e.GetProperty("kind").GetString()));
        Assert.Equal([true, false], entries.Select(e => e.GetProperty("editable").GetBoolean()));
    }

    [Fact]
    public async Task Another_users_log_is_invisible_and_untouchable()
    {
        using var factory = new AppApiFactory(new ManualClock(Wednesday));
        var james = await SignedUp(factory, "james");
        var sam = await SignedUp(factory, "sam");

        var mine = await (await james.PostAsJsonAsync("/api/log/vice", new { amount = 4 })).Content.ReadFromJsonAsync<JsonElement>();
        var id = mine.GetProperty("id").GetGuid();

        var samsView = await sam.GetFromJsonAsync<JsonElement>("/api/dashboard");
        Assert.Empty(samsView.GetProperty("week").GetProperty("entries").EnumerateArray());
        Assert.Equal(HttpStatusCode.Conflict, (await sam.DeleteAsync($"/api/log/{id}")).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await sam.PutAsJsonAsync($"/api/log/{id}", new { amount = 0 })).StatusCode);

        Assert.Single((await james.GetFromJsonAsync<JsonElement>("/api/dashboard")).GetProperty("week").GetProperty("entries").EnumerateArray());
    }

    [Fact]
    public async Task The_newest_entry_can_be_edited_and_deleted_over_HTTP()
    {
        using var factory = new AppApiFactory(new ManualClock(Wednesday));
        var client = await SignedUp(factory, "james");
        var e = await (await client.PostAsJsonAsync("/api/log/vice", new { amount = 4 })).Content.ReadFromJsonAsync<JsonElement>();
        var id = e.GetProperty("id").GetGuid();

        Assert.Equal(1, (await (await client.PutAsJsonAsync($"/api/log/{id}", new { amount = 1 })).Content.ReadFromJsonAsync<JsonElement>()).GetProperty("amount").GetDouble());
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync($"/api/log/{id}", new { amount = -1 })).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await client.DeleteAsync($"/api/log/{id}")).StatusCode);
        Assert.Empty((await client.GetFromJsonAsync<JsonElement>("/api/dashboard")).GetProperty("week").GetProperty("entries").EnumerateArray());
    }

    [Fact]
    public async Task A_new_week_shows_the_settlement_until_dismissed_and_last_week_stays_browsable()
    {
        var clock = new ManualClock(Wednesday);
        using var factory = new AppApiFactory(clock);
        var client = await SignedUp(factory, "james");
        await client.GetAsync("/api/dashboard"); // first visit records the date
        await client.PostAsJsonAsync("/api/log/activity", new { type = "Run", amount = 5 }); // 25 points

        clock.Now = Wednesday.AddDays(5);
        var d = await client.GetFromJsonAsync<JsonElement>("/api/dashboard");
        Assert.Equal("Promoted", d.GetProperty("settlement").GetProperty("outcome").GetString());
        Assert.Equal("Novice", d.GetProperty("league").GetProperty("tier").GetString());
        Assert.True(d.GetProperty("week").GetProperty("hasEarlier").GetBoolean());

        var last = await client.GetFromJsonAsync<JsonElement>("/api/dashboard?week=-1");
        Assert.Single(last.GetProperty("week").GetProperty("entries").EnumerateArray());
        Assert.False(last.GetProperty("week").GetProperty("entries")[0].GetProperty("editable").GetBoolean());

        Assert.Equal(HttpStatusCode.NoContent, (await client.PostAsync("/api/settlement/dismiss", null)).StatusCode);
        Assert.Equal(JsonValueKind.Null, (await client.GetFromJsonAsync<JsonElement>("/api/dashboard")).GetProperty("settlement").ValueKind);
    }
}
