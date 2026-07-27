import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  static Future<void> exportWidgetToPdf(GlobalKey key, String fileName) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not find RepaintBoundary on the provided GlobalKey.');
      }

      // Capture high-resolution image
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes.');
      }
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Create PDF Document
      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(pngBytes);

      // Create a single page that perfectly fits the image dimensions
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            image.width.toDouble(),
            image.height.toDouble(),
            marginAll: 0,
          ),
          build: (pw.Context context) {
            return pw.Image(pdfImage, fit: pw.BoxFit.fill);
          },
        ),
      );

      // Trigger standard save/print dialog
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '$fileName.pdf',
      );
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      rethrow;
    }
  }
}
