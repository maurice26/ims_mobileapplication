namespace inventory_management_system.Models
{
    public class Supplier
    {
        public int SupplierId { get; set; }
        public string Name { get; set; } = null!;
        public string? ContactInfo { get; set; }
        public DateTime CreatedAt { get; set; }

        // Navigation
        public List<Purchase> Purchases { get; set; } = new();
    }
}
