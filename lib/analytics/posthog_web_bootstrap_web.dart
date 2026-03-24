// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

Completer<void>? _bootstrapCompleter;

Future<void> bootstrapPosthogWeb({
  required String apiKey,
  required String host,
  required bool debug,
}) {
  if (_bootstrapCompleter != null) {
    return _bootstrapCompleter!.future;
  }

  _bootstrapCompleter = Completer<void>();

  () async {
    try {
      final normalizedHost = _normalizeHost(host);
      if (normalizedHost.isEmpty) {
        _bootstrapCompleter?.complete();
        return;
      }

      if (js_util.getProperty(html.window, 'posthog') == null) {
        await _ensurePosthogScriptLoaded('$normalizedHost/static/array.js');
      }

      final posthog = js_util.getProperty(html.window, 'posthog');
      if (posthog == null) {
        _bootstrapCompleter?.complete();
        return;
      }

      final options = js_util.jsify(<String, Object>{
        'api_host': normalizedHost,
        'capture_pageview': false,
      });

      js_util.callMethod(posthog, 'init', <Object>[apiKey, options]);
      if (debug) {
        js_util.callMethod(posthog, 'debug', <Object>[true]);
      }
    } catch (_) {
      // Best-effort bootstrap. The native Flutter wrapper remains a no-op if JS init fails.
    } finally {
      if (_bootstrapCompleter?.isCompleted == false) {
        _bootstrapCompleter?.complete();
      }
    }
  }();

  return _bootstrapCompleter!.future;
}

String _normalizeHost(String host) {
  final trimmed = host.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  return trimmed.endsWith('/')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
}

Future<void> _ensurePosthogScriptLoaded(String src) async {
  final existing =
      html.document.querySelector('script[data-posthog-bootstrap="murya"]');
  if (existing != null) {
    await _waitForPosthog();
    return;
  }

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..src = src
    ..async = true
    ..defer = true
    ..dataset['posthogBootstrap'] = 'murya';

  script.onLoad.first.then((_) {
    if (!completer.isCompleted) {
      completer.complete();
    }
  });
  script.onError.first.then((_) {
    if (!completer.isCompleted) {
      completer.complete();
    }
  });

  html.document.head?.append(script);
  await completer.future;
  await _waitForPosthog();
}

Future<void> _waitForPosthog() async {
  for (var i = 0; i < 50; i += 1) {
    if (js_util.getProperty(html.window, 'posthog') != null) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
