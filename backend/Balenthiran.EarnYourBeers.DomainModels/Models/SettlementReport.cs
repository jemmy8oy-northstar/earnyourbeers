using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.DomainModels.Models;

public record SettlementReport(double WeeklyNet, SettlementOutcome Outcome) : ISettlementReport;
