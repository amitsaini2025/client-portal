import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16)),
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        canShowScrollHead: true,
        canShowPaginationDialog: true,
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load PDF: ${details.error}')),
          );
        },
      ),
    );
  }
}
