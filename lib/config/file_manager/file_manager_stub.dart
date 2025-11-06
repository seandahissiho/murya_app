import 'dart:typed_data';

import 'file_manager.dart';

class FileManager {
  static Future<void> saveAndOpenFile(Uint8List bytes, String fileName) async {
    throw UnsupportedError("Platform not supported");
  }

  static Future<void> saveFile(Uint8List bytes, String fileName) async {
    throw UnsupportedError("Platform not supported");
  }

  static Future<dynamic> pickFile() async {
    throw UnsupportedError("Platform not supported");
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
}) =>
    throw UnsupportedError('No implementation found');

void downloadTempImpl(TempRef ref, {String? suggestedName}) {}
