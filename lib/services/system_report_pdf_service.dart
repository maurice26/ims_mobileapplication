import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SystemReportPdfService {
  Future<Uint8List> generateSystemPdf({
    required int totalUsers,
    required int totalProducts,
    required int totalSuppliers,
    required int totalSales,
    required double totalRevenue,
    required double totalPayments,
    List<Map<String, dynamic>> users = const [],
    List<Map<String, dynamic>> products = const [],
    List<Map<String, dynamic>> suppliers = const [],
    List<Map<String, dynamic>> sales = const [],
    List<Map<String, dynamic>> payments = const [],
    DateTime? generatedAt,
  }) async {
    final pdf = pw.Document();
    final generated = generatedAt ?? DateTime.now();
    final regularFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    // ── Metric card (fixed width so two fit per row) ──────────────────────
    pw.Widget metricCard(String title, String value) {
      return pw.Container(
        width: 240,
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 11,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 20)),
          ],
        ),
      );
    }

    // ── Section heading ───────────────────────────────────────────────────
    pw.Widget sectionHeading(String text) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 16, bottom: 6),
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: const pw.BoxDecoration(
          color: PdfColors.deepPurple50,
          border: pw.Border(
            left: pw.BorderSide(color: PdfColors.deepPurple300, width: 3),
          ),
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 13,
            color: PdfColors.deepPurple800,
          ),
        ),
      );
    }

    // ── Generic data table ────────────────────────────────────────────────
    pw.Widget buildTable({
      required List<String> headers,
      required List<List<String>> rows,
    }) {
      return pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        columnWidths: {
          for (int i = 0; i < headers.length; i++)
            i: const pw.FlexColumnWidth(),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            children: headers
                .map(
                  (h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      h,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 10,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          // Data rows
          ...rows.asMap().entries.map(
            (entry) => pw.TableRow(
              decoration: pw.BoxDecoration(
                color: entry.key.isEven ? PdfColors.white : PdfColors.grey50,
              ),
              children: entry.value
                  .map(
                    (cell) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        cell,
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 9,
                          color: PdfColors.grey900,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      );
    }

    // ── Page build ────────────────────────────────────────────────────────
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),

        // Header
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'IMS – System Report',
                  style: pw.TextStyle(font: boldFont, fontSize: 22),
                ),
                pw.Text(
                  _formatDateTime(generated),
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Generated by IMS Mobile App',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 11,
                color: PdfColors.grey600,
              ),
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 4),
          ],
        ),

        // Footer
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 10,
              color: PdfColors.grey500,
            ),
          ),
        ),

        build: (context) => [
          // ── Summary cards (Wrap instead of GridView) ─────────────────
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              metricCard('Total Users', totalUsers.toString()),
              metricCard('Total Products', totalProducts.toString()),
              metricCard('Total Suppliers', totalSuppliers.toString()),
              metricCard('Total Sales', totalSales.toString()),
              metricCard(
                'Total Revenue',
                '\$${totalRevenue.toStringAsFixed(2)}',
              ),
              metricCard(
                'Total Payments',
                '\$${totalPayments.toStringAsFixed(2)}',
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // ── Quick summary text ────────────────────────────────────────
          sectionHeading('Overview'),
          pw.SizedBox(height: 6),
          pw.Text(
            'Users in system: $totalUsers',
            style: pw.TextStyle(font: regularFont, fontSize: 11),
          ),
          pw.Text(
            'Products in catalog: $totalProducts',
            style: pw.TextStyle(font: regularFont, fontSize: 11),
          ),
          pw.Text(
            'Suppliers registered: $totalSuppliers',
            style: pw.TextStyle(font: regularFont, fontSize: 11),
          ),
          pw.Text(
            'Sales recorded: $totalSales',
            style: pw.TextStyle(font: regularFont, fontSize: 11),
          ),
          pw.Text(
            'Revenue from sales: \$${totalRevenue.toStringAsFixed(2)}',
            style: pw.TextStyle(font: regularFont, fontSize: 11),
          ),
          pw.Text(
            'Total payments collected: \$${totalPayments.toStringAsFixed(2)}',
            style: pw.TextStyle(font: regularFont, fontSize: 11),
          ),

          // ── Users ─────────────────────────────────────────────────────
          if (users.isNotEmpty) ...[
            sectionHeading('Users (${users.length})'),
            buildTable(
              headers: ['Name', 'Email', 'Role'],
              rows: users
                  .map(
                    (u) => [_str(u['name']), _str(u['email']), _str(u['role'])],
                  )
                  .toList(),
            ),
          ],

          // ── Suppliers ─────────────────────────────────────────────────
          if (suppliers.isNotEmpty) ...[
            sectionHeading('Suppliers (${suppliers.length})'),
            buildTable(
              headers: ['Name', 'Contact'],
              rows: suppliers
                  .map(
                    (s) => [
                      _str(s['name']),
                      _str(s['contactInfo'] ?? s['contact']),
                    ],
                  )
                  .toList(),
            ),
          ],

          // ── Products ──────────────────────────────────────────────────
          if (products.isNotEmpty) ...[
            sectionHeading('Products (${products.length})'),
            buildTable(
              headers: ['Name', 'Price', 'Stock'],
              rows: products
                  .map(
                    (p) => [
                      _str(p['name']),
                      _str(p['price']),
                      _str(p['stockQuantity'] ?? p['stock']),
                    ],
                  )
                  .toList(),
            ),
          ],

          // ── Sales ─────────────────────────────────────────────────────
          if (sales.isNotEmpty) ...[
            sectionHeading('Sales (${sales.length})'),
            buildTable(
              headers: ['Sale ID', 'Product ID', 'Qty', 'Total'],
              rows: sales
                  .map(
                    (sale) => [
                      _str(sale['id'] ?? sale['saleId']),
                      _str(sale['productId']),
                      _str(sale['quantity']),
                      _str(sale['total'] ?? sale['saleTotal']),
                    ],
                  )
                  .toList(),
            ),
          ],

          // ── Payments ──────────────────────────────────────────────────
          if (payments.isNotEmpty) ...[
            sectionHeading('Payments (${payments.length})'),
            buildTable(
              headers: ['Payment ID', 'Sale ID', 'Amount', 'Method'],
              rows: payments
                  .map(
                    (pay) => [
                      _str(pay['id'] ?? pay['paymentId']),
                      _str(pay['saleId']),
                      _str(pay['amount']),
                      _str(pay['method'] ?? pay['paymentMethod']),
                    ],
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _str(dynamic value) => value?.toString() ?? '';

  String _formatDateTime(DateTime value) {
    String dd(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${dd(value.month)}-${dd(value.day)} '
        '${dd(value.hour)}:${dd(value.minute)}';
  }
}
