import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbPrinterService {
  Future<void> findAndPrintViaUsb(BuildContext context) async {
    List<UsbDevice> devices = await UsbSerial.listDevices();

    if (devices.isNotEmpty) {
      UsbPort? port = await devices[0].create();
      if (port != null) {
        bool openResult = await port.open();
        if (!openResult) {
          print('No se pudo abrir el dispositivo');
        } else {
          await port.setDTR(true); // Data Terminal Ready
          await port.setRTS(true); // Ready To Send
          print('Conexión USB establecida con la impresora.');

          // Proceder a imprimir
          await printTicketViaUsb(port);

          port.close(); // Cierra el puerto cuando termines
        }
      }
    } else {
      // Si no hay impresoras USB, muestra un diálogo de alerta
      _showNoPrinterAlert(context);
    }
  }

  Future<void> printTicketViaUsb(UsbPort port) async {
    // Aquí va la lógica de impresión a través del puerto USB
    print('Imprimiendo ticket...');
    // Añadir lógica para enviar datos a la impresora aquí
  }

  void _showNoPrinterAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('No se encontró ningún dispositivo USB.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }
}
