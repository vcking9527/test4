namespace ELK.Demo.WebApi
{
    public static class ConfigureWebApp
    {
        public static void UseWebApp(this WebApplication app)
        {
            if (app.Environment.IsDevelopment())
            {
                app.InitSwagger();
            }

            // app.UseHttpsRedirection();
            app.UseAuthorization();
            app.MapControllers();
            app.UseCors();
        }


        private static void InitSwagger(this WebApplication app)
        {
            app.UseSwagger();
            app.UseSwaggerUI(options =>
            {
                options.SwaggerEndpoint($"/swagger/v1/swagger.json", "v1");
            });
        }
    }
}