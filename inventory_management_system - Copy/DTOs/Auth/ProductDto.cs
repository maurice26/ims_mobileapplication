namespace inventory_management_system.DTOs.Auth
{
    public class ProductDto
    {
        public string Name { get; set; } = null!;
        public decimal Price { get; set; }
        public int CategoryId { get; set; }
    }
}
