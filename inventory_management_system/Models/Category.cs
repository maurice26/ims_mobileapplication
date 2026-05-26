namespace inventory_management_system.Models
{
    public class Category
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = null!;

        // Navigation
        public List<Product> Products { get; set; } = new();
    }
}
