namespace inventory_management_system.Models
{
    public class User
    {
        public int UserId { get; set; }
        public string Name { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string Password { get; set; } = null!;
        public UserRole Role { get; set; }
        public DateTime CreatedAt { get; set; }

        // Navigation
        public List<Sale> Sales { get; set; } = new();
        public List<Purchase> Purchases { get; set; } = new();
    } 
}
