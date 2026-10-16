using Balenthiran.EarnYourBeers.Abstractions.DomainModels;

namespace Balenthiran.EarnYourBeers.DomainModels.Models;

public record Account(Guid Id, string Username) : IAccount;
