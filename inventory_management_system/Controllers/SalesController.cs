using inventory_management_system.Data;
using inventory_management_system.DTOs.Auth;
using inventory_management_system.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace inventory_management_system.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SalesController : ControllerBase
{
    private readonly AppDbContext _context;

    public SalesController(AppDbContext context)
    {
        _context = context;
    }

    // 🛒 CREATE SALE (stock decreases)
    [HttpPost]
    public async Task<IActionResult> Create(SaleDto dto)
    {
        var sale = new Sale
        {
            ProductId = dto.ProductId,
            UserId = dto.UserId,
            Quantity = dto.Quantity,
            TotalPrice = 0, // calculate later
            SaleDate = DateTime.UtcNow
        };

        _context.Sales.Add(sale);
        await _context.SaveChangesAsync();

        return Ok(sale);
    }

    // 💳 ADD PAYMENT TO SALE
    [HttpPost("{saleId}/payment")]
    public async Task<IActionResult> AddPayment(int saleId, PaymentDto dto)
    {
        var payment = new Payment
        {
            SaleId = saleId,
            Amount = dto.Amount,
            PaymentMethod = dto.PaymentMethod,
            PaymentStatus = PaymentStatus.Completed,
            PaymentDate = DateTime.UtcNow
        };

        _context.Payments.Add(payment);
        await _context.SaveChangesAsync();

        return Ok(payment);
    }

    // 📊 GET SALE WITH PAYMENTS
    [HttpGet("{id}")]
    public async Task<IActionResult> GetSale(int id)
    {
        var sale = await _context.Sales
            .Include(s => s.Product)
            .Include(s => s.Payments)
            .FirstOrDefaultAsync(s => s.SaleId == id);

        if (sale == null)
            return NotFound();

        return Ok(sale);
    }
}