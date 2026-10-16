using Balenthiran.EarnYourBeers.Abstractions.Exceptions;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.Database;
using Balenthiran.EarnYourBeers.Services;
using Microsoft.EntityFrameworkCore;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>BEH-AUTH-1: username and password accounts, and the PBKDF2 hashes under them.</summary>
public class AccountServiceTests
{
    private readonly AppDbContext _db = new(new DbContextOptionsBuilder<AppDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);
    private readonly IAccountService _accounts;

    public AccountServiceTests() => _accounts = new AccountService(_db, new Pbkdf2PasswordHasher(), TimeProvider.System);

    [Fact]
    public async Task A_registered_account_signs_in_with_its_username_in_any_case()
    {
        var made = await _accounts.RegisterAsync("James_B", "correct horse");

        var back = await _accounts.SignInAsync("  james_b ", "correct horse");

        Assert.Equal(made.Id, back.Id);
        Assert.Equal("James_B", back.Username);
    }

    [Fact]
    public async Task A_username_is_taken_ignoring_case()
    {
        await _accounts.RegisterAsync("james", "password1");

        await Assert.ThrowsAsync<ConflictException>(() => _accounts.RegisterAsync("JAMES", "password2"));
    }

    [Theory]
    [InlineData("ab")]
    [InlineData("has space")]
    [InlineData("emoji🍺")]
    [InlineData("")]
    [InlineData("abcdefghijklmnopqrstuvwxyz0123456")] // 33
    public async Task A_username_breaking_the_rule_is_refused(string username)
        => await Assert.ThrowsAsync<ValidationException>(() => _accounts.RegisterAsync(username, "long enough"));

    [Fact]
    public async Task A_password_under_eight_characters_is_refused()
        => await Assert.ThrowsAsync<ValidationException>(() => _accounts.RegisterAsync("james", "1234567"));

    [Fact]
    public async Task A_wrong_password_and_an_unknown_username_fail_the_same_way()
    {
        await _accounts.RegisterAsync("james", "password1");

        var wrong = await Assert.ThrowsAsync<UnauthorizedException>(() => _accounts.SignInAsync("james", "password2"));
        var unknown = await Assert.ThrowsAsync<UnauthorizedException>(() => _accounts.SignInAsync("nobody", "password1"));

        Assert.Equal(wrong.Message, unknown.Message);
    }

    [Fact]
    public async Task The_password_is_never_stored()
    {
        await _accounts.RegisterAsync("james", "password1");

        var stored = (await _db.Users.SingleAsync()).PasswordHash;
        Assert.DoesNotContain("password1", stored);
        Assert.StartsWith("pbkdf2-sha256$", stored);
    }

    // ---- Pbkdf2PasswordHasher ----

    [Fact]
    public void A_hash_verifies_its_password_and_no_other()
    {
        var hasher = new Pbkdf2PasswordHasher();
        var hash = hasher.Hash("correct horse");

        Assert.True(hasher.Verify("correct horse", hash));
        Assert.False(hasher.Verify("correct horsf", hash));
    }

    [Fact]
    public void The_same_password_hashes_differently_each_time()
    {
        var hasher = new Pbkdf2PasswordHasher();

        Assert.NotEqual(hasher.Hash("same"), hasher.Hash("same"));
    }

    [Theory]
    [InlineData("")]
    [InlineData("plain")]
    [InlineData("pbkdf2-sha256$x$a$b")]
    [InlineData("pbkdf2-sha256$1000$not-base64!$also-not")]
    [InlineData("md5$1$YQ==$YQ==")]
    public void A_malformed_hash_never_verifies(string stored)
        => Assert.False(new Pbkdf2PasswordHasher().Verify("anything", stored));
}
