using inventory_management_system.Data;
using inventory_management_system.DTOs.Auth;
using inventory_management_system.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace inventory_management_system.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PurchaseController : ControllerBase
{
    private readonly AppDbContext _context;

    public PurchaseController(AppDbContext context)
    {
        _context = context;
    }

    [HttpPost]
    [HttpPost]
    public async Task<IActionResult> Create(PurchaseDto dto)
    {
        var purchase = new Purchase
        {
            SupplierId = dto.SupplierId,
            UserId = dto.UserId,
            TotalCost = dto.TotalCost,
            PurchaseDate = DateTime.UtcNow
        };

        _context.Purchases.Add(purchase);
        await _context.SaveChangesAsync();

        return Ok(purchase);
    }
}
