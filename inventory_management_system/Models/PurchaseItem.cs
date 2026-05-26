namespace inventory_management_system.Models
{
    public class PurchaseItem
    {
        public int PurchaseItemId { get; set; }
        public int PurchaseId { get; set; }
        public int ProductId { get; set; }

        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }

        // Navigation
        public Purchase Purchase { get; set; } = null!;
        public Product Product { get; set; } = null!;
    }
}
