enum LandingActor {
  system,
  user,
}

extension LandingActorExtension on LandingActor {
  String get value {
    switch (this) {
      case LandingActor.system:
        return "SYSTEM";
      case LandingActor.user:
        return "USER";
    }
  }

  static LandingActor fromValue(String? value) {
    switch (value) {
      case "SYSTEM":
        return LandingActor.system;
      case "USER":
      default:
        return LandingActor.user;
    }
  }
}

enum LandingAction {
  add,
  remove,
}

extension LandingActionExtension on LandingAction {
  String get value {
    switch (this) {
      case LandingAction.add:
        return "ADD";
      case LandingAction.remove:
        return "REMOVE";
    }
  }

  static LandingAction fromValue(String? value) {
    switch (value) {
      case "REMOVE":
        return LandingAction.remove;
      case "ADD":
      default:
        return LandingAction.add;
    }
  }
}

class LandingModule {
  final String moduleId;
  final int order;
  final LandingActor addedBy;
  final DateTime? addedAt;

  const LandingModule({
    required this.moduleId,
    required this.order,
    required this.addedBy,
    this.addedAt,
  });

  factory LandingModule.fromJson(Map<String, dynamic> json) {
    return LandingModule(
      moduleId: json['moduleId'] ?? '',
      order: json['order'] ?? json['position'] ?? json['index'] ?? 0,
      addedBy: LandingActorExtension.fromValue(json['addedBy']),
      addedAt: json['addedAt'] != null ? DateTime.tryParse(json['addedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'order': order,
      'addedBy': addedBy.value,
      'addedAt': addedAt?.toIso8601String(),
    };
  }
}

class LandingEvent {
  final String id;
  final String moduleId;
  final LandingAction action;
  final LandingActor actor;
  final DateTime? createdAt;

  const LandingEvent({
    required this.id,
    required this.moduleId,
    required this.action,
    required this.actor,
    this.createdAt,
  });

  factory LandingEvent.fromJson(Map<String, dynamic> json) {
    return LandingEvent(
      id: json['id'] ?? '',
      moduleId: json['moduleId'] ?? '',
      action: LandingActionExtension.fromValue(json['action']),
      actor: LandingActorExtension.fromValue(json['actor']),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'action': action.value,
      'actor': actor.value,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
