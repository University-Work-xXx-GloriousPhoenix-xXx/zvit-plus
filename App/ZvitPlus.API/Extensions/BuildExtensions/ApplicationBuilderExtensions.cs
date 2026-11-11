using Scalar.AspNetCore;
using ZvitPlus.DAL.Context;
using ZvitPlus.DAL.Context.DataFactory;

namespace ZvitPlus.API.Extensions.BuildExtensions
{
    public static class ApplicationBuilderExtensions
    {
        public static WebApplication UseSwaggerIfDevelopment(
            this WebApplication app)
        {
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
                app.MapScalarApiReference(options =>
                {
                    options
                        .WithTitle("Zvit+ API")
                        .WithOpenApiRoutePattern("/swagger/{documentName}/swagger.json");
                });
            }

            return app;
        }

        public static WebApplication EnsureDatabaseCreated(
            this WebApplication app,
            int maxAttempts = 10)
        {
            using var scope = app.Services.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ZvitPlusDbContext>();
            var logger = scope.ServiceProvider
                .GetRequiredService<ILoggerFactory>()
                .CreateLogger("DatabaseInit");

            for (var attempt = 1; ; attempt++)
            {
                try
                {
                    db.Database.EnsureCreated();
                    logger.LogInformation("База даних готова");
                    return app;
                }
                catch (Exception ex) when (attempt < maxAttempts)
                {
                    logger.LogWarning("БД недоступна (спроба {Attempt}/{Max}): {Message}",
                        attempt, maxAttempts, ex.Message);
                    Thread.Sleep(TimeSpan.FromSeconds(5));
                }
            }
        }

        public async static Task<WebApplication> SeedTestData(
            this WebApplication app)
        {
            if (app.Configuration.GetValue<bool>("SeedTestData"))
            {
                using var scope = app.Services.CreateScope();
                var dataFactory = scope.ServiceProvider.GetRequiredService<IDataFactory>();
                await dataFactory.InitializeAsync();
            }

            return app;
        }
    }
}
