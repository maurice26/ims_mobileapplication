namespace inventory_management_system.GraphQL.Inputs;

public class SaleInput
{
    public int ProductId { get; set; }
    public int UserId { get; set; }
    public int Quantity { get; set; }
}