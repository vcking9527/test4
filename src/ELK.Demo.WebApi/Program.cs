using ELK.Demo.WebApi;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddServices(builder.Configuration);

var app = builder.Build();
app.UseWebApp();
app.Run();
