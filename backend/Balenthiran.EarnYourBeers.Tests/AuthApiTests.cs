using System.Net;
using System.Net.Http.Json;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>BEH-AUTH-1 over HTTP: the cookie a sign-up sets is what makes /me answer.</summary>
public class AuthApiTests
{
    [Fact]
    public async Task Sign_up_signs_you_in_and_sign_out_signs_you_out()
    {
        using var factory = new AppApiFactory();
        var client = factory.CreateClient();

        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/auth/me")).StatusCode);

        var created = await client.PostAsJsonAsync("/api/auth/register", new { username = "james", password = "correct horse" });
        Assert.Equal(HttpStatusCode.Created, created.StatusCode);
        var cookie = Assert.Single(created.Headers.GetValues("Set-Cookie"));
        Assert.Contains("eyb.session=", cookie);
        Assert.Contains("httponly", cookie, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("samesite=lax", cookie, StringComparison.OrdinalIgnoreCase);

        var me = await client.GetFromJsonAsync<Me>("/api/auth/me");
        Assert.Equal("james", me!.Username);

        Assert.Equal(HttpStatusCode.NoContent, (await client.PostAsync("/api/auth/logout", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/auth/me")).StatusCode);
    }

    [Fact]
    public async Task Sign_in_works_with_the_right_password_and_is_401_with_the_wrong_one()
    {
        using var factory = new AppApiFactory();
        var signup = factory.CreateClient();
        await signup.PostAsJsonAsync("/api/auth/register", new { username = "james", password = "correct horse" });

        var stranger = factory.CreateClient();
        Assert.Equal(HttpStatusCode.Unauthorized, (await stranger.PostAsJsonAsync("/api/auth/login", new { username = "james", password = "wrong horse" })).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await stranger.GetAsync("/api/auth/me")).StatusCode);

        Assert.Equal(HttpStatusCode.OK, (await stranger.PostAsJsonAsync("/api/auth/login", new { username = "JAMES", password = "correct horse" })).StatusCode);
        Assert.Equal("james", (await stranger.GetFromJsonAsync<Me>("/api/auth/me"))!.Username);
    }

    [Fact]
    public async Task A_taken_username_is_409_and_a_short_password_is_400()
    {
        using var factory = new AppApiFactory();
        var client = factory.CreateClient();
        await client.PostAsJsonAsync("/api/auth/register", new { username = "james", password = "correct horse" });

        var other = factory.CreateClient();
        Assert.Equal(HttpStatusCode.Conflict, (await other.PostAsJsonAsync("/api/auth/register", new { username = "James", password = "another one" })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await other.PostAsJsonAsync("/api/auth/register", new { username = "sam", password = "short" })).StatusCode);
    }

    [Fact]
    public async Task A_form_post_from_another_site_cannot_sign_anyone_up()
    {
        // text/plain is the content type a cross-site form can send without a CORS preflight.
        using var factory = new AppApiFactory();
        var client = factory.CreateClient();

        var r = await client.PostAsync("/api/auth/register", new StringContent("""{"username":"x","password":"yyyyyyyy"}""", System.Text.Encoding.UTF8, "text/plain"));

        Assert.Equal(HttpStatusCode.UnsupportedMediaType, r.StatusCode);
    }

    private sealed record Me(string Username);
}
