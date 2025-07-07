import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  static Future<void> generateAndOpenPdf(List<(String, String, double)> transactions, String groupName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Expense Split Summary', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Group: $groupName', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              ...transactions.map((t) => pw.Text('${t.$1} owes ${t.$2} ₹${t.$3.toStringAsFixed(2)}')),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/split_summary.pdf");
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

}

