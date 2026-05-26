using System.Text;
using inventory_management_system.Models;
using iText.Kernel.Pdf;
using iText.Layout;
using iText.Layout.Element;

namespace inventory_management_system.Services
{
    public class ReportService
    {
        // ================= CSV =================
        public string GenerateSalesCsv(List<Sale> sales)
        {
            var sb = new StringBuilder();
            sb.AppendLine("SaleId,ProductId,Quantity,TotalPrice");

            foreach (var s in sales)
            {
                sb.AppendLine($"{s.SaleId},{s.ProductId},{s.Quantity},{s.TotalPrice}");
            }

            return sb.ToString();
        }

        // ================= PDF =================
        public byte[] GenerateReceipt(Sale sale)
        {
            using var stream = new MemoryStream();

            var writer = new PdfWriter(stream);
            var pdf = new PdfDocument(writer);
            var doc = new Document(pdf);

            doc.Add(new Paragraph("INVOICE RECEIPT"));
            doc.Add(new Paragraph($"Sale ID: {sale.SaleId}"));
            doc.Add(new Paragraph($"Total: {sale.TotalPrice}"));

            doc.Close();

            return stream.ToArray();
        }
    }
}