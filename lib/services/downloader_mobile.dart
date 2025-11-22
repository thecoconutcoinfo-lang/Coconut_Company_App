import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

Future<String?> downloadFile(String content, String fileName) async {
  try {
    final Uint8List bytes = utf8.encode(content);

    String? path = await FileSaver.instance.saveFile(
      name: fileName, // Pass the full filename with extension
      bytes: bytes,
      mimeType: MimeType.csv,
    );

    return path;
  } catch (e) {
    throw Exception('Failed to save file: $e');
  }
}
