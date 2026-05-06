namespace inventory_management_system.Models
{
    public class Purchase
    {
        public int PurchaseId { get; set; }
        public int SupplierId { get; set; }
        public int UserId { get; set; }
        public DateTime PurchaseDate { get; set; }
        public decimal TotalCost { get; set; }

        // Navigation
        public Supplier Supplier { get; set; } = null!;
        public User User { get; set; } = null!;
        public List<PurchaseItem> Items { get; set; } = new();
    }
}
