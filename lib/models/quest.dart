enum QuestScope { user, userJob, all }

extension QuestScopeApiValue on QuestScope {
  String get apiValue {
    switch (this) {
      case QuestScope.user:
        return 'USER';
      case QuestScope.userJob:
        return 'USER_JOB';
      case QuestScope.all:
        return 'ALL';
    }
  }

  static QuestScope fromJsonValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'USER':
        return QuestScope.user;
      case 'USER_JOB':
        return QuestScope.userJob;
      case 'ALL':
        return QuestScope.all;
      default:
        return QuestScope.user;
    }
  }
}

class QuestDefinition {
  final String? id;
  final String? code;
  final String? title;
  final String? description;
  final String? period;
  final String? category;
  final String? scope;
  final String? eventKey;
  final int? targetCount;
  final Map<String, dynamic>? meta;
  final String? parentId;
  final int? uiOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QuestDefinition({
    this.id,
    this.code,
    this.title,
    this.description,
    this.period,
    this.category,
    this.scope,
    this.eventKey,
    this.targetCount,
    this.meta,
    this.parentId,
    this.uiOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory QuestDefinition.fromJson(Map<String, dynamic> json) {
    return QuestDefinition(
      id: json['id'] as String?,
      code: json['code'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      period: json['period'] as String?,
      category: json['category'] as String?,
      scope: json['scope'] as String?,
      eventKey: json['eventKey'] as String?,
      targetCount: _parseInt(json['targetCount']),
      meta: _parseMap(json['meta']),
      parentId: json['parentId'] as String?,
      uiOrder: _parseInt(json['uiOrder']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

class QuestInstance {
  final String? id;
  final String? userId;
  final String? userJobId;
  final String? questDefinitionId;
  final DateTime? periodStartAt;
  final DateTime? periodEndAt;
  final int progressCount;
  final String? status;
  final Map<String, dynamic>? meta;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QuestInstance({
    this.id,
    this.userId,
    this.userJobId,
    this.questDefinitionId,
    this.periodStartAt,
    this.periodEndAt,
    this.progressCount = 0,
    this.status,
    this.meta,
    this.completedAt,
    this.claimedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory QuestInstance.fromJson(Map<String, dynamic> json) {
    return QuestInstance(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      userJobId: json['userJobId'] as String?,
      questDefinitionId: json['questDefinitionId'] as String?,
      periodStartAt: _parseDate(json['periodStartAt']),
      periodEndAt: _parseDate(json['periodEndAt']),
      progressCount: _parseInt(json['progressCount']) ?? 0,
      status: json['status'] as String?,
      meta: _parseMap(json['meta']),
      completedAt: _parseDate(json['completedAt']),
      claimedAt: _parseDate(json['claimedAt']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static QuestInstance empty() => const QuestInstance();
}

class QuestReward {
  final String? id;
  final String? questDefinitionId;
  final String? currency;
  final int amount;
  final DateTime? createdAt;

  const QuestReward({
    this.id,
    this.questDefinitionId,
    this.currency,
    this.amount = 0,
    this.createdAt,
  });

  factory QuestReward.fromJson(Map<String, dynamic> json) {
    return QuestReward(
      id: json['id'] as String?,
      questDefinitionId: json['questDefinitionId'] as String?,
      currency: json['currency'] as String?,
      amount: _parseInt(json['amount']) ?? 0,
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

class QuestItem {
  final QuestDefinition? definition;
  final QuestInstance? instance;
  final List<QuestReward> rewards;
  final String? scope;
  final bool locked;
  final String? lockedReason;
  final bool claimable;
  final bool isRequired;
  final int? uiOrder;

  const QuestItem({
    this.definition,
    this.instance,
    this.rewards = const [],
    this.scope,
    this.locked = false,
    this.lockedReason,
    this.claimable = false,
    this.isRequired = false,
    this.uiOrder,
  });

  factory QuestItem.fromJson(Map<String, dynamic> json) {
    return QuestItem(
      definition: json['definition'] is Map<String, dynamic>
          ? QuestDefinition.fromJson(Map<String, dynamic>.from(json['definition'] as Map))
          : null,
      instance: json['instance'] is Map<String, dynamic>
          ? QuestInstance.fromJson(Map<String, dynamic>.from(json['instance'] as Map))
          : null,
      rewards: _parseList(json['rewards'], (item) => QuestReward.fromJson(Map<String, dynamic>.from(item as Map))),
      scope: json['scope'] as String?,
      locked: json['locked'] as bool? ?? false,
      lockedReason: json['lockedReason'] as String?,
      claimable: json['claimable'] as bool? ?? false,
      isRequired: json['isRequired'] as bool? ?? false,
      uiOrder: _parseInt(json['uiOrder']),
    );
  }

  QuestItem copyWith({
    QuestDefinition? definition,
    QuestInstance? instance,
    List<QuestReward>? rewards,
    String? scope,
    bool? locked,
    String? lockedReason,
    bool? claimable,
    bool? isRequired,
    int? uiOrder,
  }) {
    return QuestItem(
      definition: definition ?? this.definition,
      instance: instance ?? this.instance,
      rewards: rewards ?? this.rewards,
      scope: scope ?? this.scope,
      locked: locked ?? this.locked,
      lockedReason: lockedReason ?? this.lockedReason,
      claimable: claimable ?? this.claimable,
      isRequired: isRequired ?? this.isRequired,
      uiOrder: uiOrder ?? this.uiOrder,
    );
  }
}

class QuestGroupDefinition {
  final String? id;
  final String? code;
  final String? title;
  final String? description;
  final int? uiOrder;
  final String? scope;

  const QuestGroupDefinition({
    this.id,
    this.code,
    this.title,
    this.description,
    this.uiOrder,
    this.scope,
  });

  factory QuestGroupDefinition.fromJson(Map<String, dynamic> json) {
    return QuestGroupDefinition(
      id: json['id'] as String?,
      code: json['code'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      uiOrder: _parseInt(json['uiOrder']),
      scope: json['scope'] as String?,
    );
  }
}

class QuestGroupInstance {
  final String? id;
  final String? userId;
  final String? userJobId;
  final String? questGroupId;
  final String? status;
  final int requiredTotal;
  final int requiredCompleted;
  final int optionalTotal;
  final int optionalCompleted;
  final DateTime? periodStartAt;
  final DateTime? periodEndAt;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QuestGroupInstance({
    this.id,
    this.userId,
    this.userJobId,
    this.questGroupId,
    this.status,
    this.requiredTotal = 0,
    this.requiredCompleted = 0,
    this.optionalTotal = 0,
    this.optionalCompleted = 0,
    this.periodStartAt,
    this.periodEndAt,
    this.completedAt,
    this.claimedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory QuestGroupInstance.fromJson(Map<String, dynamic> json) {
    return QuestGroupInstance(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      userJobId: json['userJobId'] as String?,
      questGroupId: json['questGroupId'] as String?,
      status: json['status'] as String?,
      requiredTotal: _parseInt(json['requiredTotal']) ?? 0,
      requiredCompleted: _parseInt(json['requiredCompleted']) ?? 0,
      optionalTotal: _parseInt(json['optionalTotal']) ?? 0,
      optionalCompleted: _parseInt(json['optionalCompleted']) ?? 0,
      periodStartAt: _parseDate(json['periodStartAt']),
      periodEndAt: _parseDate(json['periodEndAt']),
      completedAt: _parseDate(json['completedAt']),
      claimedAt: _parseDate(json['claimedAt']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

class QuestGroup {
  final QuestGroupDefinition? group;
  final QuestGroupInstance? instance;
  final int requiredTotal;
  final int requiredCompleted;
  final int optionalTotal;
  final int optionalCompleted;
  final bool completed;
  final List<QuestItem> items;

  const QuestGroup({
    this.group,
    this.instance,
    this.requiredTotal = 0,
    this.requiredCompleted = 0,
    this.optionalTotal = 0,
    this.optionalCompleted = 0,
    this.completed = false,
    this.items = const [],
  });

  factory QuestGroup.fromJson(Map<String, dynamic> json) {
    return QuestGroup(
      group: json['group'] is Map<String, dynamic>
          ? QuestGroupDefinition.fromJson(Map<String, dynamic>.from(json['group'] as Map))
          : null,
      instance: json['instance'] is Map<String, dynamic>
          ? QuestGroupInstance.fromJson(Map<String, dynamic>.from(json['instance'] as Map))
          : null,
      requiredTotal: _parseInt(json['requiredTotal']) ?? 0,
      requiredCompleted: _parseInt(json['requiredCompleted']) ?? 0,
      optionalTotal: _parseInt(json['optionalTotal']) ?? 0,
      optionalCompleted: _parseInt(json['optionalCompleted']) ?? 0,
      completed: json['completed'] as bool? ?? false,
      items: _parseList(json['items'], (item) => QuestItem.fromJson(Map<String, dynamic>.from(item as Map))),
    );
  }

  QuestGroup copyWith({
    QuestGroupDefinition? group,
    QuestGroupInstance? instance,
    int? requiredTotal,
    int? requiredCompleted,
    int? optionalTotal,
    int? optionalCompleted,
    bool? completed,
    List<QuestItem>? items,
  }) {
    return QuestGroup(
      group: group ?? this.group,
      instance: instance ?? this.instance,
      requiredTotal: requiredTotal ?? this.requiredTotal,
      requiredCompleted: requiredCompleted ?? this.requiredCompleted,
      optionalTotal: optionalTotal ?? this.optionalTotal,
      optionalCompleted: optionalCompleted ?? this.optionalCompleted,
      completed: completed ?? this.completed,
      items: items ?? this.items,
    );
  }
}

class QuestList {
  final String? userJobId;
  final QuestItem? main;
  final List<QuestItem> branches;
  final List<QuestItem> others;
  final List<QuestGroup> groups;

  const QuestList({
    this.userJobId,
    this.main,
    this.branches = const [],
    this.others = const [],
    this.groups = const [],
  });

  factory QuestList.fromJson(Map<String, dynamic> json) {
    return QuestList(
      userJobId: json['userJobId'] as String?,
      main: json['main'] is Map<String, dynamic>
          ? QuestItem.fromJson(Map<String, dynamic>.from(json['main'] as Map))
          : null,
      branches: _parseList(json['branches'], (item) => QuestItem.fromJson(Map<String, dynamic>.from(item as Map))),
      others: _parseList(json['others'], (item) => QuestItem.fromJson(Map<String, dynamic>.from(item as Map))),
      groups: _parseList(json['groups'], (item) => QuestGroup.fromJson(Map<String, dynamic>.from(item as Map))),
    );
  }

  QuestList copyWith({
    String? userJobId,
    QuestItem? main,
    List<QuestItem>? branches,
    List<QuestItem>? others,
    List<QuestGroup>? groups,
  }) {
    return QuestList(
      userJobId: userJobId ?? this.userJobId,
      main: main ?? this.main,
      branches: branches ?? this.branches,
      others: others ?? this.others,
      groups: groups ?? this.groups,
    );
  }

  QuestList updateInstance(QuestInstance updated) {
    QuestItem? updateItem(QuestItem? item) {
      if (item == null) return null;
      if (item.instance?.id != updated.id) return item;
      final bool isClaimed = (updated.status ?? '').toUpperCase() == 'CLAIMED';
      return item.copyWith(
        instance: updated,
        claimable: isClaimed ? false : item.claimable,
      );
    }

    List<QuestItem> updateItems(List<QuestItem> items) {
      return items.map((item) => updateItem(item) ?? item).toList();
    }

    List<QuestGroup> updateGroups(List<QuestGroup> items) {
      return items
          .map((group) => group.copyWith(items: updateItems(group.items)))
          .toList();
    }

    return copyWith(
      main: updateItem(main),
      branches: updateItems(branches),
      others: updateItems(others),
      groups: updateGroups(groups),
    );
  }

  static QuestList empty() => const QuestList();
}

class QuestGroupList {
  final String? userJobId;
  final List<QuestGroup> groups;

  const QuestGroupList({
    this.userJobId,
    this.groups = const [],
  });

  factory QuestGroupList.fromJson(Map<String, dynamic> json) {
    return QuestGroupList(
      userJobId: json['userJobId'] as String?,
      groups: _parseList(json['groups'], (item) => QuestGroup.fromJson(Map<String, dynamic>.from(item as Map))),
    );
  }

  QuestGroupList copyWith({
    String? userJobId,
    List<QuestGroup>? groups,
  }) {
    return QuestGroupList(
      userJobId: userJobId ?? this.userJobId,
      groups: groups ?? this.groups,
    );
  }

  QuestGroupList updateInstance(QuestInstance updated) {
    List<QuestItem> updateItems(List<QuestItem> items) {
      return items.map((item) {
        if (item.instance?.id != updated.id) return item;
        final bool isClaimed = (updated.status ?? '').toUpperCase() == 'CLAIMED';
        return item.copyWith(
          instance: updated,
          claimable: isClaimed ? false : item.claimable,
        );
      }).toList();
    }

    return copyWith(
      groups: groups.map((group) => group.copyWith(items: updateItems(group.items))).toList(),
    );
  }

  static QuestGroupList empty() => const QuestGroupList();
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

Map<String, dynamic>? _parseMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<T> _parseList<T>(dynamic value, T Function(dynamic) mapper) {
  if (value is List) {
    return value.map(mapper).toList();
  }
  return <T>[];
}
