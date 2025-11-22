
import 'dart:html' as html;

Future<String?> downloadFile(String content, String fileName) async {
  final blob = html.Blob([content]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
  return null; // No file path to return on web
}
