namespace inventory_management_system.GraphQL.Inputs;

public class PurchaseItemInput
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}
