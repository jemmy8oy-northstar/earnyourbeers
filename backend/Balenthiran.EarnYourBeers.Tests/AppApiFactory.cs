using Balenthiran.EarnYourBeers.Database;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Balenthiran.EarnYourBeers.Tests;

/// <summary>
/// The real WebApi in-process with a database: EF's in-memory provider, one fresh store per
/// factory, and optionally a clock the test moves. <see cref="StatusApiFactory"/> stays
/// database-free on purpose; this is for the routes that need one.
/// </summary>
public sealed class AppApiFactory(TimeProvider? clock = null) : WebApplicationFactory<Program>
{
    private readonly string _store = Guid.NewGuid().ToString();

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.ConfigureServices(s =>
        {
            s.AddDbContext<AppDbContext>(o => o.UseInMemoryDatabase(_store));
            if (clock is not null)
            {
                s.AddSingleton(clock);
            }
        });
    }
}
