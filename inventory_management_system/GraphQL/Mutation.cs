using inventory_management_system.Data;
using inventory_management_system.GraphQL.Inputs;
using inventory_management_system.GraphQL.Types;
using inventory_management_system.Models;
using inventory_management_system.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;

namespace inventory_management_system.GraphQL;

public class Mutation
{
    // ================= USERS =================

    [Authorize(Roles = "Admin")]
    public async Task<User> CreateUser(
        CreateUserInput input,
        [Service] AppDbContext context)
    {
        if (!Enum.TryParse<UserRole>(input.Role, true, out var role))
        {
            throw new Exception($"Invalid role: {input.Role}");
        }

        var existingUser = await context.Users
            .AnyAsync(u => u.Email == input.Email);

        if (existingUser)
        {
            throw new Exception("Email already exists");
        }

        var hashedPassword = BCrypt.Net.BCrypt.HashPassword(input.Password);

        var user = new User
        {
            Name = input.Name,
            Email = input.Email,
            Password = hashedPassword,
            Role = role,
            CreatedAt = DateTime.UtcNow
        };

        context.Users.Add(user);
        await context.SaveChangesAsync();

        return user;
    }

    [Authorize(Roles = "Admin")]
    public async Task<User?> UpdateUser(
        UpdateUserInput input,
        [Service] AppDbContext context)
    {
        var user = await context.Users.FindAsync(input.UserId);
        if (user == null) return null;

        if (!Enum.TryParse<UserRole>(input.Role, true, out var role))
        {
            throw new Exception($"Invalid role: {input.Role}");
        }

        user.Name = input.Name;
        user.Email = input.Email;
        user.Role = role;

        await context.SaveChangesAsync();

        return user;
    }

    [Authorize(Roles = "Admin")]
    public async Task<bool> DeleteUser(
        int userId,
        [Service] AppDbContext context)
    {
        var user = await context.Users.FindAsync(userId);
        if (user == null) return false;

        context.Users.Remove(user);
        await context.SaveChangesAsync();

        return true;
    }

    public async Task<AuthPayload> Login(
        LoginInput input,
        [Service] AppDbContext context,
        [Service] AuthService authService)
    {
        var user = await context.Users
            .FirstOrDefaultAsync(u => u.Email == input.Email);

        if (user == null)
            throw new Exception("User not found");

        if (!BCrypt.Net.BCrypt.Verify(input.Password, user.Password))
            throw new Exception("Invalid password");

        var token = authService.GenerateToken(user);

        return new AuthPayload
        {
            Token = token,
            User = user
        };
    }

    // ================= PRODUCTS =================

    [Authorize(Roles = "Admin,Sales")]
    public async Task<Product> CreateProduct(
        CreateProductInput input,
        [Service] AppDbContext context)
    {
        var product = new Product
        {
            Name = input.Name,
            Price = input.Price,
            CategoryId = input.CategoryId,
            StockQuantity = input.StockQuantity
        };

        context.Products.Add(product);
        await context.SaveChangesAsync();

        return product;
    }

    [Authorize]
    public async Task<Product?> UpdateProduct(
        UpdateProductInput input,
        [Service] AppDbContext context)
    {
        var product = await context.Products.FindAsync(input.ProductId);
        if (product == null) return null;

        product.Name = input.Name;
        product.Price = input.Price;
        product.CategoryId = input.CategoryId;
        product.StockQuantity = input.StockQuantity;

        await context.SaveChangesAsync();

        return product;
    }

    [Authorize(Roles = "Admin,Sales")]
    public async Task<bool> DeleteProduct(
        int productId,
        [Service] AppDbContext context)
    {
        var product = await context.Products.FindAsync(productId);
        if (product == null) return false;

        context.Products.Remove(product);
        await context.SaveChangesAsync();

        return true;
    }

    // ================= SALES =================

    [Authorize(Roles = "Admin,Sales")]
    public async Task<Sale> CreateSale(
        SaleInput input,
        [Service] AppDbContext context)
    {
        using var transaction = await context.Database.BeginTransactionAsync();

        var product = await context.Products.FindAsync(input.ProductId);
        if (product == null)
            throw new Exception("Product not found");

        if (product.StockQuantity < input.Quantity)
            throw new Exception("Not enough stock");

        product.StockQuantity -= input.Quantity;

        var sale = new Sale
        {
            ProductId = input.ProductId,
            UserId = input.UserId,
            Quantity = input.Quantity,
            TotalPrice = product.Price * input.Quantity,
            SaleDate = DateTime.UtcNow
        };

        context.Sales.Add(sale);

        await context.SaveChangesAsync();
        await transaction.CommitAsync();

        return sale;
    }

    // ================= PURCHASES =================

    [Authorize]
    public async Task<Purchase> CreatePurchase(
        PurchaseInput input,
        [Service] AppDbContext context)
    {
        using var transaction = await context.Database.BeginTransactionAsync();

        var purchase = new Purchase
        {
            SupplierId = input.SupplierId,
            UserId = input.UserId,
            PurchaseDate = DateTime.UtcNow,
            TotalCost = 0
        };

        context.Purchases.Add(purchase);
        await context.SaveChangesAsync();

        decimal totalCost = 0;

        foreach (var item in input.Items)
        {
            var product = await context.Products.FindAsync(item.ProductId);
            if (product == null)
                throw new Exception("Product not found");

            product.StockQuantity += item.Quantity;

            var purchaseItem = new PurchaseItem
            {
                PurchaseId = purchase.PurchaseId,
                ProductId = item.ProductId,
                Quantity = item.Quantity,
                UnitPrice = item.UnitPrice
            };

            totalCost += item.Quantity * item.UnitPrice;

            context.PurchaseItems.Add(purchaseItem);
        }

        purchase.TotalCost = totalCost;

        await context.SaveChangesAsync();
        await transaction.CommitAsync();

        return purchase;
    }

    // ================= SUPPLIERS =================

    [Authorize]
    public async Task<Supplier> CreateSupplier(
        SupplierInput input,
        [Service] AppDbContext context)
    {
        var supplier = new Supplier
        {
            Name = input.Name,
            ContactInfo = input.ContactInfo,
            CreatedAt = DateTime.UtcNow
        };

        context.Suppliers.Add(supplier);
        await context.SaveChangesAsync();

        return supplier;
    }

    [Authorize]
    public async Task<Supplier?> UpdateSupplier(
        int supplierId,
        SupplierInput input,
        [Service] AppDbContext context)
    {
        var supplier = await context.Suppliers.FindAsync(supplierId);
        if (supplier == null) return null;

        supplier.Name = input.Name;
        supplier.ContactInfo = input.ContactInfo;

        await context.SaveChangesAsync();

        return supplier;
    }

    [Authorize(Roles = "Admin")]
    public async Task<bool> DeleteSupplier(
        int supplierId,
        [Service] AppDbContext context)
    {
        var supplier = await context.Suppliers.FindAsync(supplierId);
        if (supplier == null) return false;

        context.Suppliers.Remove(supplier);
        await context.SaveChangesAsync();

        return true;
    }

    // ================= PAYMENTS =================

    [Authorize(Roles = "Admin,Sales")]
    public async Task<Payment> AddPayment(
        int saleId,
        decimal amount,
        string method,
        [Service] AppDbContext context)
    {
        var sale = await context.Sales.FindAsync(saleId);
        if (sale == null)
            throw new Exception("Sale not found");

        var payment = new Payment
        {
            SaleId = saleId,
            Amount = amount,
            PaymentMethod = method,
            PaymentStatus = PaymentStatus.Completed,
            PaymentDate = DateTime.UtcNow
        };

        context.Payments.Add(payment);
        await context.SaveChangesAsync();

        return payment;
    }

    // ================= REPORTS =================

    public async Task<string> ExportSalesCsv(
        [Service] AppDbContext context,
        [Service] ReportService reportService)
    {
        var sales = await context.Sales.ToListAsync();
        return reportService.GenerateSalesCsv(sales);
    }

    public async Task<string> GetReceipt(
        int saleId,
        [Service] AppDbContext context,
        [Service] ReportService reportService)
    {
        var sale = await context.Sales.FindAsync(saleId);

        if (sale == null)
            throw new Exception("Sale not found");

        var pdfBytes = reportService.GenerateReceipt(sale);

        return Convert.ToBase64String(pdfBytes);
    }
}
