namespace Balenthiran.EarnYourBeers.Abstractions.Services;

/// <summary>Turns a password into a stored hash and checks one against it (BEH-AUTH-1).</summary>
public interface IPasswordHasher
{
    string Hash(string password);

    /// <summary>True when <paramref name="password"/> produced <paramref name="stored"/>; false for any malformed hash.</summary>
    bool Verify(string password, string stored);
}
