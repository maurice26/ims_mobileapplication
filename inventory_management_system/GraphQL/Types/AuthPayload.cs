using inventory_management_system.Models;

namespace inventory_management_system.GraphQL.Types
{
    public class AuthPayload
    {
        public string Token { get; set; }
        public User User { get; set; }
    }
}
