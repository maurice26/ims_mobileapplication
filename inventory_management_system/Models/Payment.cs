namespace inventory_management_system.Models
{
    public class Payment
    {
        public int PaymentId { get; set; }
        public int SaleId { get; set; }

        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; } = null!;
        public PaymentStatus PaymentStatus { get; set; }
        public DateTime PaymentDate { get; set; }

        // Navigation
        public Sale Sale { get; set; } = null!;
    }
}
