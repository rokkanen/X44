using Company.Template.Data;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Company.Template.Api
{
    /// <summary>
    /// Entity Framework configuration class
    /// </summary>
    public static class EFConfig
    {
        public static void ConfigureServices(IServiceCollection services, IConfiguration configuration)
        {
            services.AddDbContext<DatabaseContext>(options => options.UseSqlServer(configuration.GetConnectionString("DatabaseContext")));
        }

        public static void Configure(IApplicationBuilder app)
        {
            using (var serviceScope = app.ApplicationServices.GetRequiredService<IServiceScopeFactory>().CreateScope())
            {
                //serviceScope.ServiceProvider.GetService<DatabaseContext>().Database.Migrate();
                var context = serviceScope.ServiceProvider.GetService<DatabaseContext>();
                context.Database.EnsureCreated();
            }
        }
    }
}
