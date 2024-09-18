import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';

class PrinterService {
  Future<void> printTicket() async {
    // Define tu impresora
    final printerIp = '192.168.0.100'; // Cambia esta IP por la de tu impresora
    final profile =
        await CapabilityProfile.load(); // Cargar el perfil de la impresora
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    final res =
        await printer.connect(printerIp, port: 9100); // Conectar a la impresora
    if (res == PosPrintResult.success) {
      // Diseña el ticket
      printer.text(
        'TICKET DE PRUEBA',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      printer.text('Fecha: 2024-09-17');
      printer.text('Ticket N°: 00123');
      printer.hr(); // Línea horizontal

      // Productos
      printer.row([
        PosColumn(text: 'Producto', width: 6),
        PosColumn(text: 'Cant.', width: 2),
        PosColumn(
            text: 'Precio',
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      printer.row([
        PosColumn(text: 'Pan', width: 6),
        PosColumn(text: '1', width: 2),
        PosColumn(
            text: '5000 Gs.',
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      printer.hr();
      printer.text('Total: 5000 Gs.',
          styles: const PosStyles(align: PosAlign.right));

      // Genera un código QR
      printer.qrcode('https://example.com', size: QRSize.Size4);

      // Cortar el papel
      printer.cut();
      printer.disconnect();
    } else {
      print('Error al conectar con la impresora: $res');
    }
  }
}
