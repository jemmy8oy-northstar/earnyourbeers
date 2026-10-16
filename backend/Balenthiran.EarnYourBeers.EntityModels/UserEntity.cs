namespace Balenthiran.EarnYourBeers.EntityModels;

/// <summary>An account (BEH-AUTH-1): a username and a password hash. No email, by his choice.</summary>
public class UserEntity
{
    public Guid Id { get; set; }

    /// <summary>As typed at sign-up, for display.</summary>
    public required string Username { get; set; }

    /// <summary>Lower-cased, so "James" and "james" are one account.</summary>
    public required string NormalisedUsername { get; set; }

    public required string PasswordHash { get; set; }

    public DateTime CreatedAt { get; set; }
}
