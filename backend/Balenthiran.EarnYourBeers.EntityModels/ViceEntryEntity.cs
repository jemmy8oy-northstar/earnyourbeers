namespace Balenthiran.EarnYourBeers.EntityModels;

/// <summary>A logged vice (BEH-LOG-1), in units; each costs one point. One user's row.</summary>
public class ViceEntryEntity
{
    public Guid Id { get; set; }

    public required string UserId { get; set; }

    public double Amount { get; set; }

    public DateTime LoggedAt { get; set; }
}
