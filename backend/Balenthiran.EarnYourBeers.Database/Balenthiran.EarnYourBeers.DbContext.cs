using Balenthiran.EarnYourBeers.EntityModels;
using Microsoft.EntityFrameworkCore;

namespace Balenthiran.EarnYourBeers.Database;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<ActivityEntryEntity> ActivityEntries => Set<ActivityEntryEntity>();

    public DbSet<ViceEntryEntity> ViceEntries => Set<ViceEntryEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Every read is one user's entries in a time window (BEH-AUTH-2, BEH-BALANCE-1).
        modelBuilder.Entity<ActivityEntryEntity>(e =>
        {
            e.Property(x => x.Type).HasConversion<string>().HasMaxLength(16);
            e.HasIndex(x => new { x.UserId, x.LoggedAt });
        });
        modelBuilder.Entity<ViceEntryEntity>(e => e.HasIndex(x => new { x.UserId, x.LoggedAt }));
    }
}
