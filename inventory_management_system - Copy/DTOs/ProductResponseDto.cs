namespace inventory_management_system.DTOs
{
    public class ProductResponseDto
    {
        public int ProductId { get; set; }
        public string Name { get; set; } = null!;
        public decimal Price { get; set; }
    }
}
