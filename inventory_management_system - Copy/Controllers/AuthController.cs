using inventory_management_system.Data;
using inventory_management_system.DTOs.Auth;
using inventory_management_system.Models;
using inventory_management_system.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace inventory_management_system.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly AuthService _authService;
    private readonly IConfiguration _config;

    public AuthController(AppDbContext context, AuthService authService, IConfiguration config)
    {
        _context = context;
        _authService = authService;
        _config = config;
    }

    // 🔐 REGISTER
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterDto dto)
    {
        if (await _context.Users.AnyAsync(u => u.Email == dto.Email))
            return BadRequest("Email already exists");

        var user = new User
        {
            Name = dto.Name,
            Email = dto.Email,
            Role = UserRole.Sales,
            CreatedAt = DateTime.UtcNow
        };

        // ✅ HASH PASSWORD CORRECTLY
        user.Password = _authService.HashPassword(user, dto.Password);

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return Ok(new
        {
            user.UserId,
            user.Name,
            user.Email,
            role = user.Role.ToString()
        });
    }

    // 🔐 LOGIN
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);

        if (user == null || !_authService.VerifyPassword(user, dto.Password))
            return Unauthorized("Invalid credentials");

        var token = GenerateJwt(user);

        return Ok(new
        {
            token,
            user = new
            {
                user.UserId,
                user.Name,
                user.Email,
                role = user.Role.ToString()
            }
        });
    }

    private string GenerateJwt(User user)
    {
        var jwt = _config.GetSection("Jwt");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt["Key"]!));

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role.ToString())
        };

        var token = new JwtSecurityToken(
            issuer: jwt["Issuer"],
            audience: jwt["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(3),
            signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256)
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}