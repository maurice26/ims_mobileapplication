namespace inventory_management_system.GraphQL.Inputs;

public class CreateProductInput
{
    public string Name { get; set; }
    public decimal Price { get; set; }
    public int CategoryId { get; set; }
}