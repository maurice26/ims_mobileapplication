using inventory_management_system.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Text;

namespace inventory_management_system.Controllers
{
    [ApiController]
    [Route("api/reports")]
    [Authorize]
    public class ReportsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ReportsController(AppDbContext context)
        {
            _context = context;
        }

        // GET /api/reports/sales
        [HttpGet("sales")]
        public IActionResult GetSalesCSV()
        {
            var sales = _context.Sales
                .Select(s => new {
                    s.SaleId,
                    s.ProductId,
                    s.UserId,
                    s.Quantity,
                    s.TotalPrice,
                    s.SaleDate
                }).ToList();

            var csv = new StringBuilder();
            csv.AppendLine("SaleId,ProductId,UserId,Quantity,TotalPrice,SaleDate");

            foreach (var s in sales)
                csv.AppendLine($"{s.SaleId},{s.ProductId},{s.UserId},{s.Quantity},{s.TotalPrice},{s.SaleDate}");

            var bytes = Encoding.UTF8.GetBytes(csv.ToString());
            return File(bytes, "text/csv", "sales.csv");
        }

        // GET /api/reports/receipt/{id}
        [HttpGet("receipt/{id}")]
        public IActionResult GetReceipt(int id)
        {
            var sale = _context.Sales
                .Where(s => s.SaleId == id)
                .Select(s => new {
                    s.SaleId,
                    s.Quantity,
                    s.TotalPrice,
                    s.SaleDate,
                    ProductName = s.Product.Name
                }).FirstOrDefault();

            if (sale == null) return NotFound();

            // Plain text receipt as PDF-ready response
            var content = new StringBuilder();
            content.AppendLine("===== RECEIPT =====");
            content.AppendLine($"Sale ID   : {sale.SaleId}");
            content.AppendLine($"Product   : {sale.ProductName}");
            content.AppendLine($"Quantity  : {sale.Quantity}");
            content.AppendLine($"Total     : ${sale.TotalPrice}");
            content.AppendLine($"Date      : {sale.SaleDate:yyyy-MM-dd}");
            content.AppendLine("===================");

            var bytes = Encoding.UTF8.GetBytes(content.ToString());
            return File(bytes, "text/plain", $"receipt_{id}.txt");
        }
    }
}