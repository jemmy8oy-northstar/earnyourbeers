using Balenthiran.EarnYourBeers.Abstractions.DomainModels;

namespace Balenthiran.EarnYourBeers.DomainModels.Models;

public record LeagueTier(string Name, string Division) : ILeagueTier;
