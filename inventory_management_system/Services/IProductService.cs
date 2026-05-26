using inventory_management_system.Models;

namespace inventory_management_system.Services;

public interface IProductService
{
    Task<IEnumerable<Product>> GetAll();
    Task<Product?> GetById(int id);
    Task<Product> Create(Product product);
    Task<Product?> Update(int id, Product updated);
    Task<bool> Delete(int id);
}
