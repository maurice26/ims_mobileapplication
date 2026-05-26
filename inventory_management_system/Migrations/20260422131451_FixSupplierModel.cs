using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace inventory_management_system.Migrations
{
    /// <inheritdoc />
    public partial class FixSupplierModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ContactInfo",
                table: "Suppliers",
                newName: "contactInfo");

            migrationBuilder.AddColumn<string>(
                name: "ContactInfo",
                table: "Suppliers",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ContactInfo",
                table: "Suppliers");

            migrationBuilder.RenameColumn(
                name: "contactInfo",
                table: "Suppliers",
                newName: "ContactInfo");
        }
    }
}
