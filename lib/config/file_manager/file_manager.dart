export 'file_manager_stub.dart'
    if (dart.library.html) 'file_manager_web.dart'
    if (dart.library.io) 'file_manager_mobile.dart';

/// Cross-platform handle to the saved data.
class TempRef {
  /// On mobile/desktop: absolute file path.
  /// On web: blob: URL (call [dispose] to revoke).
  final String location;
  final dynamic file;

  /// Call on web to revoke the object URL. No-op on IO.
  final void Function() dispose;

  TempRef({
    required this.location,
    required this.file,
    required this.dispose,
  });
}

/// Optional helper (Web only): triggers a download dialog.
/// No-op on IO.
// void downloadTemp(TempRef ref, {String? suggestedName}) => downloadTempImpl(ref, suggestedName: suggestedName);
