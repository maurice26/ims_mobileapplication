using inventory_management_system.Data;
using inventory_management_system.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using inventory_management_system.GraphQL;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// 🔐 JWT Configuration
var jwtSettings = builder.Configuration.GetSection("Jwt");
var jwtKey = jwtSettings["Key"] ?? throw new Exception("JWT Key is missing");

var key = Encoding.UTF8.GetBytes(jwtKey);

// 🗄️ PostgreSQL
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// 🧠 Services
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<AuthService>();

// 🌐 Controllers (REST API)
builder.Services.AddControllers();

// 🔐 Authentication (JWT)
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = true;
    options.SaveToken = true;

    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,

        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],

        IssuerSigningKey = new SymmetricSecurityKey(key)
    };
});

// 🔒 Authorization (Global Protection)
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = options.DefaultPolicy;
});

// 📄 Swagger + JWT Support
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "Inventory API", Version = "v1" });

    // 🔐 Add JWT Auth
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter: Bearer {your token}"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

// 🔗 GraphQL
// 🔗 GraphQL
builder.Services
    .AddGraphQLServer()
    .AddQueryType<inventory_management_system.GraphQL.Query>()
    .AddMutationType<inventory_management_system.GraphQL.Mutation>()
    .AddProjections()
    .AddFiltering()
    .AddSorting()      
    .AddAuthorization()
    .AddProjections();

var app = builder.Build();

// ⚙️ Middleware Pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// 🔐 MUST BE IN THIS ORDER
app.UseAuthentication();
app.UseAuthorization();

// 📡 Endpoints
app.MapControllers();        // REST API
app.MapGraphQL("/graphql").AllowAnonymous();  // GraphQL API

app.Run();