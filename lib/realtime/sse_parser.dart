import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'sse_event.dart';

class SseParser {
  SseParser({this.logger});

  final void Function(String message)? logger;

  String? _eventType;
  String? _eventId;
  final StringBuffer _dataBuffer = StringBuffer();

  SseEvent? parseLine(String line) {
    if (line.endsWith('\r')) {
      line = line.substring(0, line.length - 1);
    }
    if (line.isEmpty) {
      return _dispatchEvent();
    }
    if (line.startsWith(':')) {
      return null;
    }

    final split = _splitField(line);
    switch (split.key) {
      case 'event':
        _eventType = split.value;
        break;
      case 'id':
        _eventId = split.value;
        break;
      case 'data':
        if (_dataBuffer.isNotEmpty) {
          _dataBuffer.write('\n');
        }
        _dataBuffer.write(split.value);
        break;
      default:
        break;
    }
    return null;
  }

  SseEvent? _dispatchEvent() {
    if (_eventType == null && _eventId == null && _dataBuffer.isEmpty) {
      _reset();
      return null;
    }

    final rawData = _dataBuffer.toString();
    Map<String, dynamic> dataMap = const {};
    if (rawData.isNotEmpty) {
      try {
        final decoded = json.decode(rawData);
        if (decoded is Map<String, dynamic>) {
          dataMap = decoded;
        } else {
          _log('SSE data is not a JSON object: $decoded');
          _reset();
          return null;
        }
      } catch (error) {
        _log('Invalid SSE JSON: $error');
        _reset();
        return null;
      }
    }

    final event = SseEvent(
      type: _eventType ?? 'message',
      id: (_eventId?.isEmpty ?? true) ? null : _eventId,
      receivedAt: DateTime.now(),
      data: dataMap,
    );
    _reset();
    return event;
  }

  MapEntry<String, String> _splitField(String line) {
    final index = line.indexOf(':');
    if (index == -1) {
      return MapEntry(line, '');
    }
    var value = line.substring(index + 1);
    if (value.startsWith(' ')) {
      value = value.substring(1);
    }
    return MapEntry(line.substring(0, index), value);
  }

  void _reset() {
    _eventType = null;
    _eventId = null;
    _dataBuffer.clear();
  }

  void _log(String message) {
    if (logger != null) {
      logger!(message);
      return;
    }
    debugPrint(message);
  }
}
