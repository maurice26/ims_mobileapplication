using inventory_management_system.Data;
using inventory_management_system.Services;
using inventory_management_system.GraphQL;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// ================= 🔐 JWT CONFIG =================
var jwtSettings = builder.Configuration.GetSection("Jwt");
var jwtKey = jwtSettings["Key"] ?? throw new Exception("JWT Key is missing");

var key = Encoding.UTF8.GetBytes(jwtKey);

// ================= 🗄️ DATABASE =================
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"))
);

// ================= 🧠 SERVICES =================
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<ReportService>();

// ================= 🌐 CONTROLLERS =================
builder.Services.AddControllers();

// ================= 🌍 CORS — FIXED FOR FLUTTER =================
// Flutter Android emulator uses 10.0.2.2 to reach host machine
// Flutter iOS simulator uses localhost or 127.0.0.1
// Physical devices use your machine's local IP (e.g. 192.168.x.x)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy
            .AllowAnyOrigin()   // ✅ Allows Flutter on any IP/port
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

// ================= 🔐 AUTHENTICATION =================
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    // ✅ FIXED: Allow HTTP during development (Flutter dev server)
    options.RequireHttpsMetadata = false;
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

// ================= 🔒 AUTHORIZATION =================
builder.Services.AddAuthorization();

// ================= 📄 SWAGGER =================
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Inventory API",
        Version = "v1"
    });

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

// ================= 🔗 GRAPHQL =================
builder.Services
    .AddGraphQLServer()
    .AddQueryType<Query>()
    .AddMutationType<Mutation>()
    .ModifyRequestOptions(opt => opt.IncludeExceptionDetails = true)
    .AddProjections()
    .AddFiltering()
    .AddSorting()
    .AddAuthorization();

// ================= 🚀 BUILD =================
var app = builder.Build();

// ================= ⚙️ MIDDLEWARE =================
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ✅ Comment out HTTPS redirect in development so Flutter HTTP works
// app.UseHttpsRedirection();

// ✅ CORS MUST come before auth — now uses AllowAll policy
app.UseCors("AllowAll");

// 🔐 Auth middleware
app.UseAuthentication();
app.UseAuthorization();

// ================= 📡 ENDPOINTS =================
app.MapControllers();

// ✅ Allow login without token
app.MapGraphQL("/graphql").AllowAnonymous();

// ================= 🚀 RUN =================
app.Run();