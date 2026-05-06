using inventory_management_system.Models;
using Microsoft.AspNetCore.Identity;
using System.Security.Cryptography;
using System.Text;

public class AuthService
{
    private readonly PasswordHasher<User> _passwordHasher = new();

    // 🔐 HASH PASSWORD
    public string HashPassword(User user, string password)
    {
        return _passwordHasher.HashPassword(user, password);
    }

    // 🔐 VERIFY PASSWORD
    public bool VerifyPassword(User user, string password)
    {
        var result = _passwordHasher.VerifyHashedPassword(user, user.Password, password);
        return result == PasswordVerificationResult.Success;
    }
}
