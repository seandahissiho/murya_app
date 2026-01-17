class SseEvent {
  final String type;
  final String? id;
  final DateTime receivedAt;
  final Map<String, dynamic> data;

  const SseEvent({
    required this.type,
    required this.id,
    required this.receivedAt,
    required this.data,
  });
}
