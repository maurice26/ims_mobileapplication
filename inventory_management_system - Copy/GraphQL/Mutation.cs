using inventory_management_system.Data;
using inventory_management_system.GraphQL.Inputs;
using inventory_management_system.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;

namespace inventory_management_system.GraphQL;

public class Mutation
{
    // ================= USERS =================

    public async Task<User> CreateUser(
        CreateUserInput input,
        [Service] AppDbContext context)
    {
        var user = new User
        {
            Name = input.Name,
            Email = input.Email,
            Password = input.Password, // 🔐 hash later
            Role = UserRole.Sales,
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

        user.Name = input.Name;
        user.Email = input.Email;
        user.Role = Enum.Parse<UserRole>(input.Role);

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

    // ================= PRODUCTS =================

    [Authorize]
    public async Task<Product> CreateProduct(
        CreateProductInput input,
        [Service] AppDbContext context)
    {
        var product = new Product
        {
            Name = input.Name,
            Price = input.Price,
            CategoryId = input.CategoryId,
            StockQuantity = 0
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

        await context.SaveChangesAsync();

        return product;
    }

    [Authorize(Roles = "Admin")]
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

    [Authorize]
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

        // Reduce stock
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

    // ================= PURCHASE =================

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

            // Increase stock
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

    // ================= PAYMENTS =================

    [Authorize]
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
            PaymentStatus = PaymentStatus.Completed, // ✅ ensure enum has this
            PaymentDate = DateTime.UtcNow
        };

        context.Payments.Add(payment);
        await context.SaveChangesAsync();

        return payment;
    }
}