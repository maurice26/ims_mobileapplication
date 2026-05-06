namespace inventory_management_system.DTOs.Auth
{
    public class PurchaseDto
    {
        public int SupplierId { get; set; }
        public int UserId { get; set; }
        public decimal TotalCost { get; set; }
    }
}
