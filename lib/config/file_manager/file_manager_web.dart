import 'dart:async';
import 'dart:developer';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'file_manager.dart';

class FileManager {
  static Future<void> saveAndOpenFile(Uint8List bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<void> saveFile(Uint8List bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<dynamic> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      html.File file = html.File(result.files.single.bytes as List<Object>, result.files.single.path!);
      log("Picked file: ${file.name}, size: ${file.size} bytes");
      return file;
    }
    return null;
  }

  /// Saves [bytes] as a temporary file (IO) or blob URL (Web).
  static Future<TempRef> saveBytesAsTemp({
    required List<int> bytes,
    String filename = 'temp.bin',
    String mimeType = 'application/octet-stream',
  }) =>
      saveBytesAsTempImpl(bytes: bytes, filename: filename, mimeType: mimeType);

  /// Optional helper (Web only): triggers a download dialog.
  /// No-op on IO.
  static void downloadTemp(TempRef ref, {String? suggestedName}) => downloadTempImpl(ref, suggestedName: suggestedName);
}

Future<TempRef> saveBytesAsTempImpl({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) async {
  // Create a Blob and an object URL. Revoke later to avoid leaks.
  // https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL_static
  final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);

  return TempRef(
    location: url, // e.g. "blob:https://yourapp/...."
    file: blob,
    dispose: () {
      try {
        html.Url.revokeObjectUrl(url);
      } catch (_) {}
    },
  );
}

void downloadTempImpl(TempRef ref, {String? suggestedName}) {
  // Trigger a download using <a download>. Works cross-browser for blobs.
  final a = html.AnchorElement(href: ref.location)..download = suggestedName ?? 'download.bin';
  html.document.body?.append(a);
  a.click();
  a.remove();
}
