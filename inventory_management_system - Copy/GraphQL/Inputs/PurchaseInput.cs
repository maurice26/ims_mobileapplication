namespace inventory_management_system.GraphQL.Inputs;

public class PurchaseInput
{
    public int SupplierId { get; set; }
    public int UserId { get; set; }
    public List<PurchaseItemInput> Items { get; set; }
}
