import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:murya/config/routes.dart';
import 'package:share_plus/share_plus.dart';

class ShareUtils {
  static Future<void> shareContent({
    required String text,
    String? subject,
    String? url,
  }) async {
    final String content = url != null ? '$text\n$url' : text;

    if (kIsWeb) {
      await _shareOnWeb(content, subject: subject);
    } else {
      await _shareOnMobileDesktop(content, subject: subject);
    }
  }

  static Future<void> _shareOnMobileDesktop(String content, {String? subject}) async {
    await SharePlus.instance.share(
      ShareParams(
        text: content,
        subject: subject,
      ),
    );
  }

  static Future<void> _shareOnWeb(String content, {String? subject}) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: content,
          subject: subject,
        ),
      );
    } catch (e) {
      // Fallback if share API not supported
      await Clipboard.setData(ClipboardData(text: content));
      // Optionally: throw or return a status letting UI show "Copied to clipboard"
    }
  }

  static generateJobDetailsLink(String id) {
    final path = AppRoutes.jobDetails.replaceFirst(':id', id);
    final domain = kIsWeb ? Uri.base.origin : 'https://www.murya.app';
    return '$domain$path';
  }
}
