using inventory_management_system.Data;
using inventory_management_system.Models;
using Microsoft.AspNetCore.Authorization;

namespace inventory_management_system.GraphQL;

public class Query
{
    // USERS
    [Authorize]
    [UseFiltering]
    [UseSorting]
    public IQueryable<User> GetUsers([Service] AppDbContext context) =>
        context.Users;

    // PRODUCTS
    [UseFiltering]
    [UseSorting]
    public IQueryable<Product> GetProducts([Service] AppDbContext context) =>
        context.Products;

    // CATEGORIES
    public IQueryable<Category> GetCategories([Service] AppDbContext context) =>
        context.Categories;

    // SUPPLIERS
    public IQueryable<Supplier> GetSuppliers([Service] AppDbContext context) =>
        context.Suppliers;

    // SALES
    [Authorize]
    public IQueryable<Sale> GetSales([Service] AppDbContext context) =>
        context.Sales;

    // PURCHASES
    [Authorize]
    public IQueryable<Purchase> GetPurchases([Service] AppDbContext context) =>
        context.Purchases;

    // PAYMENTS
    [Authorize]
    public IQueryable<Payment> GetPayments([Service] AppDbContext context) =>
        context.Payments;
}