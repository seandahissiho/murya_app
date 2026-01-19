import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:murya/repositories/base.repository.dart';

import 'sse_event.dart';
import 'sse_parser.dart';

class SseService {
  SseService({
    required this.tokenProvider,
    Duration staleTimeout = const Duration(seconds: 45),
    bool enableLogging = true,
    Uri? endpoint,
    http.Client? client,
  })  : _staleTimeout = staleTimeout,
        _enableLogging = enableLogging,
        _endpoint = endpoint,
        _clientFactory = (() => client ?? http.Client()),
        _parser = SseParser(logger: enableLogging ? null : (_) {});

  final Future<String?> Function() tokenProvider;

  final Duration _staleTimeout;
  final bool _enableLogging;
  final Uri? _endpoint;
  final http.Client Function() _clientFactory;
  final SseParser _parser;

  final StreamController<SseEvent> _controller = StreamController<SseEvent>.broadcast();
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();
  StreamSubscription<String>? _lineSubscription;
  http.Client? _client;
  Timer? _reconnectTimer;
  Timer? _staleTimer;

  bool _isConnected = false;
  bool _manualDisconnect = false;
  bool _connecting = false;
  bool _webUseQueryToken = false;

  int _retryAttempt = 0;
  String? _lastEventId;
  String? _lastToken;

  Stream<SseEvent> get events => _controller.stream;
  Stream<bool> get connectionStatus => _statusController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_connecting || _isConnected) {
      return;
    }
    _manualDisconnect = false;
    _connecting = true;
    await _openConnection();
    _connecting = false;
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _staleTimer?.cancel();
    await _closeCurrent();
  }

  Future<void> _openConnection() async {
    try {
      final token = await tokenProvider();
      _lastToken = token;
      if (token == null || token.isEmpty) {
        _log('SSE token missing, retrying.');
        _scheduleReconnect();
        return;
      }

      final uri = _buildUri(token);
      final headers = _buildHeaders(token);

      _client = _clientFactory();
      final request = http.Request('GET', uri);
      request.headers.addAll(headers);

      final response = await _client!.send(request);
      if (response.statusCode != 200) {
        _log('SSE connect failed (${response.statusCode}).');
        await _closeCurrent();
        _handleWebFallback();
        _scheduleReconnect();
        return;
      }

      _retryAttempt = 0;
      _setConnectionStatus(true);
      _log('SSE connected.');
      _startStaleTimer();

      _lineSubscription = response.stream.transform(utf8.decoder).transform(const LineSplitter()).listen(
        _handleLine,
        onError: (error) {
          _log('SSE stream error: $error');
          _handleStreamClosed();
        },
        onDone: _handleStreamClosed,
        cancelOnError: true,
      );
    } catch (error) {
      _log('SSE connect error: $error');
      _handleWebFallback();
      _scheduleReconnect();
    }
  }

  Uri _buildUri(String token) {
    final base = _endpoint ?? Uri.parse(ApiEndPoint.baseUrl);
    final query = <String, String>{};
    if (kIsWeb && _webUseQueryToken && token.isNotEmpty) {
      query['access_token'] = token;
    }
    return base.replace(
      path: '/api/realtime/stream',
      queryParameters: query.isEmpty ? null : query,
    );
  }

  Map<String, String> _buildHeaders(String token) {
    final headers = <String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };
    if (!_webUseQueryToken || !kIsWeb) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (_lastEventId != null && _lastEventId!.isNotEmpty) {
      headers['Last-Event-ID'] = _lastEventId!;
    }
    return headers;
  }

  void _handleLine(String line) {
    final event = _parser.parseLine(line);
    if (event == null) {
      return;
    }
    if (event.id != null) {
      _lastEventId = event.id;
    }
    _restartStaleTimer();
    // _log('SSE event: ${event.type}');
    _controller.add(event);
  }

  void _handleStreamClosed() {
    _staleTimer?.cancel();
    _closeCurrent();
    if (_manualDisconnect) {
      return;
    }
    _scheduleReconnect();
  }

  void _startStaleTimer() {
    _staleTimer?.cancel();
    _staleTimer = Timer(_staleTimeout, () {
      _log('SSE stale timeout reached.');
      _handleStreamClosed();
    });
  }

  void _restartStaleTimer() {
    if (!_isConnected) {
      return;
    }
    _startStaleTimer();
  }

  void _scheduleReconnect() {
    if (_manualDisconnect) {
      return;
    }
    _reconnectTimer?.cancel();
    const backoff = [1, 2, 4, 8, 15];
    final index = _retryAttempt.clamp(0, backoff.length - 1);
    final delay = Duration(seconds: backoff[index]);
    _retryAttempt = (_retryAttempt + 1).clamp(0, backoff.length - 1);
    _log('SSE reconnecting in ${delay.inSeconds}s.');
    _reconnectTimer = Timer(delay, () {
      if (_manualDisconnect) {
        return;
      }
      connect();
    });
  }

  Future<void> _closeCurrent() async {
    await _lineSubscription?.cancel();
    _lineSubscription = null;
    _client?.close();
    _client = null;
    final wasConnected = _isConnected;
    _setConnectionStatus(false);
    if (wasConnected) {
      _log('SSE disconnected.');
    }
  }

  void _setConnectionStatus(bool connected) {
    if (_isConnected == connected) {
      return;
    }
    _isConnected = connected;
    _statusController.add(connected);
  }

  void _handleWebFallback() {
    if (!kIsWeb) {
      return;
    }
    if (_webUseQueryToken) {
      return;
    }
    if (_lastToken == null || _lastToken!.isEmpty) {
      return;
    }
    _webUseQueryToken = true;
    _retryAttempt = 0;
    _log('SSE web fallback enabled (query access_token).');
  }

  void _log(String message) {
    if (!_enableLogging) {
      return;
    }
    debugPrint(message);
  }
}
