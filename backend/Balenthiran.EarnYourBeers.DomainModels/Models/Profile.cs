using Balenthiran.EarnYourBeers.Abstractions.DomainModels;

namespace Balenthiran.EarnYourBeers.DomainModels.Models;

public record Profile(int Level, double Tally, string ViceEmoji, bool Onboarded, ISettlementReport? PendingReport) : IProfile;
