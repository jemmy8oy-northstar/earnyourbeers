using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.DomainModels.Models;

public record SettlementResult(int Level, double Tally, SettlementOutcome Outcome) : ISettlementResult;
