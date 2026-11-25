var builder = WebApplication.CreateBuilder(args);

// Connection strings are supplied via environment variables, e.g.
// ConnectionStrings__Postgres, ConnectionStrings__RabbitMq, ConnectionStrings__Redis.
// They are not consumed yet.

var app = builder.Build();

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.Run();

public partial class Program;
