namespace Balenthiran.EarnYourBeers.Abstractions.DomainModels;

/// <summary>A signed-up person (BEH-AUTH-1). Never carries the password hash.</summary>
public interface IAccount
{
    Guid Id { get; }

    string Username { get; }
}
