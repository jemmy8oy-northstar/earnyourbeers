using Balenthiran.EarnYourBeers.Abstractions.Services;
using Balenthiran.EarnYourBeers.Services;
using Balenthiran.EarnYourBeers.Database;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.EntityFrameworkCore;

namespace Balenthiran.EarnYourBeers.WebApi;

public static class ServiceRegistration
{
    public static void AddBackendServices(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection");
        var dataProtection = services.AddDataProtection().SetApplicationName("earnyourbeers");
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            Console.WriteLine("[WARNING] No database connection string configured — database features are disabled.");
        }
        else
        {
            services.AddDbContext<AppDbContext>(options =>
                options.UseNpgsql(connectionString, b => b.MigrationsAssembly("Balenthiran.EarnYourBeers.Database")));
            dataProtection.PersistKeysToDbContext<AppDbContext>();
        }

        services.AddAutoMapper(cfg => cfg.AddMaps(AppDomain.CurrentDomain.GetAssemblies()));
        services.AddScoped<IStatusService, StatusService>();
        services.AddSingleton<IScoring, Scoring>();
        services.AddSingleton<ILeague, League>();
        services.AddSingleton(TimeProvider.System);
        services.AddScoped<ILogService, LogService>();
        services.AddSingleton<IPasswordHasher, Pbkdf2PasswordHasher>();
        services.AddScoped<IAccountService, AccountService>();
        services.AddScoped<IProfileService, ProfileService>();
    }
}
