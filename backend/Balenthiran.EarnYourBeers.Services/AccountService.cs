using System.Text.RegularExpressions;
using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Exceptions;
using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.Database;
using Balenthiran.EarnYourBeers.DomainModels.Models;
using Balenthiran.EarnYourBeers.EntityModels;
using Microsoft.EntityFrameworkCore;

namespace Balenthiran.EarnYourBeers.Services;

/// <summary>BEH-AUTH-1: "username auth to keep it simple" (earnyourbeers#1). No email, no reset.</summary>
public partial class AccountService(AppDbContext db, IPasswordHasher hasher, TimeProvider clock) : IAccountService
{
    private const int MinPassword = 8;
    private const string BadCredentials = "That username and password do not match an account.";

    // A sign-in for a username that does not exist still pays for one hash, so it takes as long
    // as a wrong password and the timing does not say which usernames exist.
    private readonly Lazy<string> decoy = new(() => hasher.Hash(Guid.NewGuid().ToString()));

    public async Task<IAccount> RegisterAsync(string username, string password, CancellationToken ct = default)
    {
        username = (username ?? string.Empty).Trim();
        if (!UsernameRule().IsMatch(username))
        {
            throw new ValidationException("A username is 3 to 32 letters, digits, '.', '_' or '-'.");
        }

        if ((password ?? string.Empty).Length < MinPassword)
        {
            throw new ValidationException($"A password is at least {MinPassword} characters.");
        }

        var normalised = username.ToLowerInvariant();
        if (await db.Users.AnyAsync(u => u.NormalisedUsername == normalised, ct))
        {
            throw new ConflictException("That username is taken.");
        }

        var user = new UserEntity
        {
            Id = Guid.NewGuid(),
            Username = username,
            NormalisedUsername = normalised,
            PasswordHash = hasher.Hash(password!),
            CreatedAt = clock.GetUtcNow().UtcDateTime,
        };
        db.Users.Add(user);
        try
        {
            await db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException e)
        {
            // Two sign-ups for one name at once: the unique index is the final word.
            throw new ConflictException("That username is taken.", e);
        }

        return new Account(user.Id, user.Username);
    }

    public async Task<IAccount> SignInAsync(string username, string password, CancellationToken ct = default)
    {
        var normalised = (username ?? string.Empty).Trim().ToLowerInvariant();
        var user = await db.Users.SingleOrDefaultAsync(u => u.NormalisedUsername == normalised, ct);
        var ok = hasher.Verify(password ?? string.Empty, user?.PasswordHash ?? decoy.Value);
        if (user is null || !ok)
        {
            throw new UnauthorizedException(BadCredentials);
        }

        return new Account(user.Id, user.Username);
    }

    public async Task<IAccount?> FindAsync(Guid id, CancellationToken ct = default)
        => await db.Users.Where(u => u.Id == id).Select(u => new Account(u.Id, u.Username)).SingleOrDefaultAsync(ct);

    [GeneratedRegex("^[A-Za-z0-9._-]{3,32}$")]
    private static partial Regex UsernameRule();
}
