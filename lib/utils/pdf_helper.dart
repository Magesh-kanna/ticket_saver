import 'dart:io';
import 'package:open_filex/open_filex.dart';

class PdfHelper {
  static Future<void> openPdf(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File not found in storage. It might have been deleted.');
    }
    await OpenFilex.open(path);
  }
}
