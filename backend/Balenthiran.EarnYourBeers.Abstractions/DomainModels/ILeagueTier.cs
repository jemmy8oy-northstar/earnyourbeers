namespace Balenthiran.EarnYourBeers.Abstractions.DomainModels;

/// <summary>One of the 20 tiers (BEH-LEAGUE-1): a name, and the division of five it sits in.</summary>
public interface ILeagueTier
{
    string Name { get; }

    string Division { get; }
}
