using Balenthiran.EarnYourBeers.EntityModels;
using Microsoft.EntityFrameworkCore;

namespace Balenthiran.EarnYourBeers.Database;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<ActivityEntryEntity> ActivityEntries => Set<ActivityEntryEntity>();

    public DbSet<ViceEntryEntity> ViceEntries => Set<ViceEntryEntity>();

    public DbSet<UserEntity> Users => Set<UserEntity>();

    public DbSet<ProfileEntity> Profiles => Set<ProfileEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // BEH-AUTH-1: one account per username, ignoring case.
        modelBuilder.Entity<UserEntity>(e =>
        {
            e.Property(x => x.Username).HasMaxLength(32);
            e.Property(x => x.NormalisedUsername).HasMaxLength(32);
            e.HasIndex(x => x.NormalisedUsername).IsUnique();
        });

        // Every read is one user's entries in a time window (BEH-AUTH-2, BEH-BALANCE-1).
        modelBuilder.Entity<ActivityEntryEntity>(e =>
        {
            e.Property(x => x.Type).HasConversion<string>().HasMaxLength(16);
            e.HasIndex(x => new { x.UserId, x.LoggedAt });
        });
        modelBuilder.Entity<ViceEntryEntity>(e => e.HasIndex(x => new { x.UserId, x.LoggedAt }));
        modelBuilder.Entity<ProfileEntity>(e =>
        {
            e.HasKey(x => x.UserId);
            e.Property(x => x.ViceEmoji).HasMaxLength(16);
            e.Property(x => x.ReportOutcome).HasConversion<string>().HasMaxLength(24);
        });
    }
}
