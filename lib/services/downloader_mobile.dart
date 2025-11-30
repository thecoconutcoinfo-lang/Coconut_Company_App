import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> downloadFile(String content, String fileName) async {
  try {
    final directory = await getExternalStoragePublicDirectory(StorageDirectory.downloads);
    if (directory == null) {
      throw Exception('Could not get the downloads directory');
    }

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(content);

    return filePath;
  } catch (e) {
    throw Exception('Failed to save file: $e');
  }
}

Future<Directory?> getExternalStoragePublicDirectory(StorageDirectory downloads) async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download');
  }
  return getExternalStorageDirectory();
}
