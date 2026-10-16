namespace Balenthiran.EarnYourBeers.Abstractions.DataModels;

public interface IStatus
{
    string Version { get; set; }
    DateTime LastUpdated { get; set; }
}
