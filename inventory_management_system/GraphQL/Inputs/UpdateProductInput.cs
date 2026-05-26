namespace inventory_management_system.GraphQL.Inputs;

public class UpdateProductInput
{
    public int ProductId { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public int CategoryId { get; set; }
    public int StockQuantity { get; set; }
}
