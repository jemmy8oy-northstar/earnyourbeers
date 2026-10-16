using Balenthiran.EarnYourBeers.Abstractions.DomainModels;

namespace Balenthiran.EarnYourBeers.Abstractions.Services;

/// <summary>Sign-up and sign-in with a username and password (BEH-AUTH-1).</summary>
public interface IAccountService
{
    /// <summary>
    /// Creates an account. A username is 3 to 32 letters, digits, '.', '_' or '-', unique ignoring
    /// case; a password is at least 8 characters. Breaking a rule is a validation error; a taken
    /// username is a conflict.
    /// </summary>
    Task<IAccount> RegisterAsync(string username, string password, CancellationToken ct = default);

    /// <summary>
    /// The account these credentials belong to. An unknown username and a wrong password fail the
    /// same way, so the answer does not say which usernames exist.
    /// </summary>
    Task<IAccount> SignInAsync(string username, string password, CancellationToken ct = default);

    /// <summary>The account with this id, or null once it no longer exists.</summary>
    Task<IAccount?> FindAsync(Guid id, CancellationToken ct = default);
}
