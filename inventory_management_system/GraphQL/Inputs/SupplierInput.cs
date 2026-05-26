namespace inventory_management_system.GraphQL.Inputs
{
    public class SupplierInput
    {
        public string Name { get; set; } = null!;
        public string? ContactInfo { get; set; }
    }
}