using Microsoft.EntityFrameworkCore;
using inventory_management_system.Data;
using inventory_management_system.Models;

namespace inventory_management_system.Services;

public class ProductService : IProductService
{
    private readonly AppDbContext _context;

    public ProductService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Product>> GetAll()
    {
        return await _context.Products
            .Include(p => p.Category)
            .ToListAsync();
    }

    public async Task<Product?> GetById(int id)
    {
        return await _context.Products.FindAsync(id);
    }

    public async Task<Product> Create(Product product)
    {
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        return product;
    }

    public async Task<Product?> Update(int id, Product updated)
    {
        var product = await _context.Products.FindAsync(id);
        if (product == null) return null;

        product.Name = updated.Name;
        product.Price = updated.Price;
        product.StockQuantity = updated.StockQuantity;
        product.CategoryId = updated.CategoryId;

        await _context.SaveChangesAsync();
        return product;
    }

    public async Task<bool> Delete(int id)
    {
        var product = await _context.Products.FindAsync(id);
        if (product == null) return false;

        _context.Products.Remove(product);
        await _context.SaveChangesAsync();
        return true;
    }
}