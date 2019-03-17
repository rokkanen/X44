namespace Company.Template.Api
{
    using Data;
    using Microsoft.AspNetCore.Builder;
    using Microsoft.AspNetCore.Hosting;
    using Microsoft.EntityFrameworkCore;
    using Microsoft.Extensions.Configuration;
    using Microsoft.Extensions.DependencyInjection;
    using Microsoft.Extensions.Logging;

    public class Startup
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(typeof(Startup));
        public IConfiguration Configuration { get; }
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddMvc();
            // EFConfig.ConfigureServices(services, Configuration);
            SwaggerConfig.ConfigureServices(services);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
        {
            loggerFactory.AddLog4Net();
            log.Info("start");
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                // EFConfig.Configure(app);
            }
            SwaggerConfig.Configure(app);
            app.UseMvc();
        }
    }
}
