import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'file_manager.dart';

class FileManager {
  static Future<void> saveAndOpenFile(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    await OpenFile.open(filePath);
  }

  static Future<void> saveFile(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
  }

  static Future<dynamic> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
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
  required String mimeType, // unused on IO
}) async {
  // OS temp dir. (Dart/Flutter standard)
  // https://api.dart.dev/dart-io/Directory/systemTemp.html
  final dir = await getTemporaryDirectory();
  final ts = DateTime.now().millisecondsSinceEpoch;
  final safeName = (filename.trim().isEmpty) ? 'tmp_$ts' : filename.trim();
  final ext = filename.contains('.') ? '' : '.bin';
  final path = '${dir.path}/$safeName$ext';

  // final dir = Directory.systemTemp.createTempSync('app_tmp_');
  final file = File(path);
  // Ensure parent exists and write
  await file.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
  return TempRef(
    location: file.path,
    file: file,
    dispose: () {
      // Best-effort cleanup of the whole temp folder.
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    },
  );
}

void downloadTempImpl(TempRef ref, {String? suggestedName}) {
// Not applicable on IO; no-op.
}
