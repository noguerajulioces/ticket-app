import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // Importar Syncfusion PDF viewer
import 'dart:io'; // Para trabajar con archivos

class PdfViewerScreen extends StatelessWidget {
  final String pdfPath;

  PdfViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualizador de PDF'),
      ),
      body: SfPdfViewer.file(
        File(pdfPath),
      ),
    );
  }
}
