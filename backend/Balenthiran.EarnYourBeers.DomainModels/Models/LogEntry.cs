using Balenthiran.EarnYourBeers.Abstractions.DomainModels;
using Balenthiran.EarnYourBeers.Abstractions.Enums;

namespace Balenthiran.EarnYourBeers.DomainModels.Models;

public record LogEntry(Guid Id, LogKind Kind, ActivityType? Activity, double Amount, DateTime LoggedAt) : ILogEntry;
