namespace inventory_management_system.DTOs.Auth
{
    public class PaymentDto
    {
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; } = null!;
    }
}
