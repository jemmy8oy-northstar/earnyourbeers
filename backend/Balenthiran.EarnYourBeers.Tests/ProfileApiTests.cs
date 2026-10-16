using System.Net;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>Onboarding, the vice setting and reset over HTTP (BEH-ONBOARD-1/2, BEH-VICE-1, BEH-RESET-1).</summary>
public class ProfileApiTests
{
    private static readonly DateTimeOffset Wednesday = new(2026, 10, 14, 12, 0, 0, TimeSpan.Zero);

    private static async Task<HttpClient> SignedUp(AppApiFactory factory, string username)
    {
        var client = factory.CreateClient();
        (await client.PostAsJsonAsync("/api/auth/register", new { username, password = "correct horse" })).EnsureSuccessStatusCode();
        return client;
    }

    [Theory]
    [InlineData("POST", "/api/profile/onboard")]
    [InlineData("PUT", "/api/profile/vice")]
    [InlineData("POST", "/api/profile/reset")]
    public async Task Without_a_session_every_route_is_401(string method, string path)
    {
        using var factory = new AppApiFactory();
        var r = await factory.CreateClient().SendAsync(new HttpRequestMessage(new HttpMethod(method), path) { Content = JsonContent.Create(new { confirm = true }) });

        Assert.Equal(HttpStatusCode.Unauthorized, r.StatusCode);
    }

    [Theory]
    [InlineData("POST", "/api/profile/onboard")]
    [InlineData("PUT", "/api/profile/vice")]
    [InlineData("POST", "/api/profile/reset")]
    public async Task The_routes_take_JSON_only(string method, string path)
    {
        using var factory = new AppApiFactory();
        var client = await SignedUp(factory, "james");
        var r = await client.SendAsync(new HttpRequestMessage(new HttpMethod(method), path) { Content = new StringContent("confirm=true", Encoding.UTF8, "text/plain") });

        Assert.Equal(HttpStatusCode.UnsupportedMediaType, r.StatusCode);
    }

    [Fact]
    public async Task Onboarding_seeds_the_tier_and_shows_on_the_dashboard()
    {
        using var factory = new AppApiFactory(new ManualClock(Wednesday));
        var client = await SignedUp(factory, "james");
        Assert.False((await client.GetFromJsonAsync<JsonElement>("/api/dashboard")).GetProperty("onboarded").GetBoolean());

        var r = await client.PostAsJsonAsync("/api/profile/onboard", new { sport = "Run", weeklyVolume = 50, viceEmoji = "🎮", weeklyViceCount = 10 });

        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        var p = await r.Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(p.GetProperty("onboarded").GetBoolean());
        Assert.Equal(10, p.GetProperty("level").GetInt32());
        Assert.Equal(0, p.GetProperty("tally").GetDouble());
        var d = await client.GetFromJsonAsync<JsonElement>("/api/dashboard");
        Assert.True(d.GetProperty("onboarded").GetBoolean());
        Assert.Equal("🎮", d.GetProperty("viceEmoji").GetString());
        Assert.Equal(10, d.GetProperty("league").GetProperty("level").GetInt32());
    }

    [Fact]
    public async Task Onboarding_twice_is_409_and_bad_answers_are_400()
    {
        using var factory = new AppApiFactory(new ManualClock(Wednesday));
        var client = await SignedUp(factory, "james");

        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsJsonAsync("/api/profile/onboard", new { sport = "Run", weeklyVolume = 101, viceEmoji = "🍕", weeklyViceCount = 0 })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsJsonAsync("/api/profile/onboard", new { sport = "Run", weeklyVolume = 10, viceEmoji = "pizza", weeklyViceCount = 0 })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsJsonAsync("/api/profile/onboard", new { sport = "Hike", weeklyVolume = 10, viceEmoji = "🍕", weeklyViceCount = 0 })).StatusCode);
        Assert.False((await client.GetFromJsonAsync<JsonElement>("/api/dashboard")).GetProperty("onboarded").GetBoolean());

        Assert.Equal(HttpStatusCode.OK, (await client.PostAsJsonAsync("/api/profile/onboard", new { sport = "Swim", weeklyVolume = 600, viceEmoji = "🍕", weeklyViceCount = 5 })).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await client.PostAsJsonAsync("/api/profile/onboard", new { sport = "Run", weeklyVolume = 10, viceEmoji = "🍕", weeklyViceCount = 5 })).StatusCode);
    }

    [Fact]
    public async Task The_vice_can_be_changed_and_empty_falls_back_to_pizza()
    {
        using var factory = new AppApiFactory(new ManualClock(Wednesday));
        var client = await SignedUp(factory, "james");

        var r = await client.PutAsJsonAsync("/api/profile/vice", new { viceEmoji = "🍩" });
        Assert.Equal("🍩", (await r.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("viceEmoji").GetString());
        Assert.Equal("🍩", (await client.GetFromJsonAsync<JsonElement>("/api/dashboard")).GetProperty("viceEmoji").GetString());

        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync("/api/profile/vice", new { viceEmoji = "donut" })).StatusCode);
        var empty = await client.PutAsJsonAsync("/api/profile/vice", new { viceEmoji = "  " });
        Assert.Equal("🍕", (await empty.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("viceEmoji").GetString());
    }

    [Fact]
    public async Task Reset_needs_a_confirmation_and_wipes_only_my_data()
    {
        var clock = new ManualClock(Wednesday);
        using var factory = new AppApiFactory(clock);
        var james = await SignedUp(factory, "james");
        var sam = await SignedUp(factory, "sam");
        foreach (var c in new[] { james, sam })
        {
            (await c.PostAsJsonAsync("/api/profile/onboard", new { sport = "Run", weeklyVolume = 50, viceEmoji = "🎮", weeklyViceCount = 10 })).EnsureSuccessStatusCode();
            (await c.PostAsJsonAsync("/api/log/activity", new { type = "Run", amount = 5 })).EnsureSuccessStatusCode();
            (await c.PostAsJsonAsync("/api/log/vice", new { amount = 2 })).EnsureSuccessStatusCode();
        }

        Assert.Equal(HttpStatusCode.BadRequest, (await james.PostAsJsonAsync("/api/profile/reset", new { confirm = false })).StatusCode);
        Assert.True((await james.GetFromJsonAsync<JsonElement>("/api/dashboard")).GetProperty("onboarded").GetBoolean());

        Assert.Equal(HttpStatusCode.NoContent, (await james.PostAsJsonAsync("/api/profile/reset", new { confirm = true })).StatusCode);

        var mine = await james.GetFromJsonAsync<JsonElement>("/api/dashboard");
        Assert.False(mine.GetProperty("onboarded").GetBoolean());
        Assert.Empty(mine.GetProperty("week").GetProperty("entries").EnumerateArray());
        Assert.Equal(0, mine.GetProperty("league").GetProperty("level").GetInt32());
        Assert.Equal("🍕", mine.GetProperty("viceEmoji").GetString());

        var theirs = await sam.GetFromJsonAsync<JsonElement>("/api/dashboard");
        Assert.True(theirs.GetProperty("onboarded").GetBoolean());
        Assert.Equal(2, theirs.GetProperty("week").GetProperty("entries").GetArrayLength());
        Assert.Equal(10, theirs.GetProperty("league").GetProperty("level").GetInt32());
        Assert.Equal("🎮", theirs.GetProperty("viceEmoji").GetString());

        // The account stayed: the same session can onboard again.
        Assert.Equal(HttpStatusCode.OK, (await james.PostAsJsonAsync("/api/profile/onboard", new { sport = "Run", weeklyVolume = 10, viceEmoji = "🍕", weeklyViceCount = 0 })).StatusCode);
    }
}
