namespace inventory_management_system.Models
{
    public class Product
    {
        public int ProductId { get; set; }
        public string Name { get; set; } = null!;
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }

        public int CategoryId { get; set; }

        // Navigation
        public Category Category { get; set; } = null!;
        public List<PurchaseItem> PurchaseItems { get; set; } = new();
        public List<Sale> Sales { get; set; } = new();
    }
}
