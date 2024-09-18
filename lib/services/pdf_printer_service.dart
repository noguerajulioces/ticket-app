import 'dart:io'; // Para trabajar con archivos
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart'; // Para obtener rutas de archivos
import 'package:intl/intl.dart'; // Para formatear la fecha

class PdfPrinterService {
  /// Genera y guarda un recibo en formato PDF, luego devuelve la ruta del archivo guardado.
  Future<String> generateAndSavePdf(
      String ticketNumber, String fullName, DateTime createdAt) async {
    final pdf = pw.Document();

    // Formatear la fecha y hora
    String formattedDate = DateFormat('dd-MM-yyyy kk:mm').format(createdAt);

    // Configuración del tamaño de página para una impresora térmica (80mm)
    const pageFormat = PdfPageFormat(80 * PdfPageFormat.mm, double.infinity);

    // Generar el contenido del recibo
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text("$ticketNumber",
                  style: pw.TextStyle(
                      fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.bottomCenter,
                child: pw.Text('Nombre: $fullName',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.normal)),
              ),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.bottomCenter,
                child: pw.Text('Generado: $formattedDate',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.normal)),
              ),
            ],
          );
        },
      ),
    );

    // Obtener el directorio para guardar el archivo
    final outputDirectory = await getTemporaryDirectory();
    final outputPath = "${outputDirectory.path}/ticket_$ticketNumber.pdf";

    // Guardar el PDF en un archivo
    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());

    return outputPath; // Devolver la ruta del archivo PDF
  }
}
