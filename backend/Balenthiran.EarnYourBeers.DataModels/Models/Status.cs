using Balenthiran.EarnYourBeers.Abstractions.DataModels;

namespace Balenthiran.EarnYourBeers.DataModels.Models;

public class Status : IStatus
{
    public string Version { get; set; } = "1.0.0";
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
}
