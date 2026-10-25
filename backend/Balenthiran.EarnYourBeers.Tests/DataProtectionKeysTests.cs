using Balenthiran.EarnYourBeers.Database;
using Microsoft.AspNetCore.DataProtection.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>Auth-cookie keys live in Postgres so a redeploy doesn't sign everyone out.</summary>
public class DataProtectionKeysTests
{
    [Fact]
    public void The_model_holds_data_protection_keys()
    {
        using var db = new AppDbContext(new DbContextOptionsBuilder<AppDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);

        Assert.NotNull(db.Model.FindEntityType(typeof(DataProtectionKey)));
    }
}
