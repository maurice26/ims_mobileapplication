namespace inventory_management_system.Models
{
    public class Sale
    {
        public int SaleId { get; set; }
        public int ProductId { get; set; }
        public int UserId { get; set; }

        public int Quantity { get; set; }
        public decimal TotalPrice { get; set; }
        public DateTime SaleDate { get; set; }

        // Navigation
        public Product Product { get; set; } = null!;
        public User User { get; set; } = null!;
        public List<Payment> Payments { get; set; } = new();
    }
}
