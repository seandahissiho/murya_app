import 'dart:ui';

import 'package:murya/config/app_icons.dart';

enum ResourceType { article, podcast, video }

extension ResourceTypeX on ResourceType {
  Color get borderColor {
    switch (this) {
      case ResourceType.article:
        // rgba(255, 214, 0, 1)
        return const Color.fromRGBO(255, 214, 0, 1); // Yellowish
      case ResourceType.podcast:
        // rgba(255, 120, 73, 1)
        return const Color.fromRGBO(255, 120, 73, 1); // Reddish
      case ResourceType.video:
        // rgba(39, 245, 152, 1)
        return const Color.fromRGBO(39, 245, 152, 1); // Greenish
    }
  }

  Color get color {
    switch (this) {
      case ResourceType.article:
        // rgba(255, 214, 0, 1)
        return const Color.fromRGBO(255, 214, 0, 1); // Yellowish
      case ResourceType.podcast:
        // rgba(255, 120, 73, 1)
        return const Color.fromRGBO(255, 120, 73, 1); // Reddish
      case ResourceType.video:
        // rgba(39, 245, 152, 1)
        return const Color.fromRGBO(39, 245, 152, 1); // Greenish
    }
  }

  String toJson() => name;

  static ResourceType fromJson(String? value) {
    if (value == null) return ResourceType.article;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case "article":
        return ResourceType.article;
      case "podcast":
        return ResourceType.podcast;
      case "video":
        return ResourceType.video;
      default:
        return ResourceType.values.firstWhere(
          (e) => e.name == normalized,
          orElse: () => ResourceType.article,
        );
    }
  }
}

class Author {
  final String? id;
  final String? name;
  final String? profileUrl;

  Author({this.id, this.name, this.profileUrl});
}

class ResourceSummary {
  final List<String> sections;

  ResourceSummary({required this.sections});
}

class UserResourceState {
  final DateTime? openedAt;
  final DateTime? readAt;
  final DateTime? lastViewedAt;
  final int viewsCount;
  final double? progress;

  const UserResourceState({
    this.openedAt,
    this.readAt,
    this.lastViewedAt,
    this.viewsCount = 0,
    this.progress,
  });

  factory UserResourceState.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    final progressValue = json['progress'];
    final double? progress = progressValue is num
        ? progressValue.toDouble()
        : (progressValue is String ? double.tryParse(progressValue) : null);

    return UserResourceState(
      openedAt: parseDate(json['openedAt']),
      readAt: parseDate(json['readAt']),
      lastViewedAt: parseDate(json['lastViewedAt']),
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      progress: progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openedAt': openedAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'lastViewedAt': lastViewedAt?.toIso8601String(),
      'viewsCount': viewsCount,
      'progress': progress,
    };
  }
}

/*
model LearningResource {
  id                String                 @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  // Scope & typage
  scope             LearningResourceScope  @default(USER_JOB)
  type              LearningResourceType   @default(ARTICLE)
  source            LearningResourceSource @default(AI_GENERATED)
  // Liens métier
  jobId             String?                @db.Uuid // pour les ressources par défaut (et/ou redondance pour les ressources user)
  userJobId         String?                @db.Uuid // pour les ressources personnalisées
  // Contenu
  title             String                 @db.VarChar(255)
  slug              String?                @unique @db.VarChar(255)
  description       String?                @db.Text
  content           String?                @db.Text // article, script de podcast, transcript de vidéo, etc.
  mediaUrl          String?                @db.VarChar(1024) // URL audio/vidéo si besoin
  thumbnailUrl      String?                @db.VarChar(1024)
  languageCode      String?                @db.VarChar(16)
  estimatedDuration Int? // en secondes
  metadata          Json? // pour stocker n’importe quel extra (IDs IA, tags, etc.)
  // Audit
  createdAt         DateTime               @default(now()) @db.Timestamp(0)
  updatedAt         DateTime               @default(now()) @updatedAt @db.Timestamp(0)
  createdById       String?                @db.Uuid
  updatedById       String?                @db.Uuid
  // Relations
  job               Job?                   @relation(fields: [jobId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  userJob           UserJob?               @relation(fields: [userJobId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  createdBy         User?                  @relation(name: "LearningResourceCreatedBy", fields: [createdById], references: [id], onUpdate: Cascade, onDelete: SetNull)
  updatedBy         User?                  @relation(name: "LearningResourceUpdatedBy", fields: [updatedById], references: [id], onUpdate: Cascade, onDelete: SetNull)

  @@index([jobId], map: "idx_learning_resource_job")
  @@index([userJobId], map: "idx_learning_resource_user_job")
  @@index([scope, type], map: "idx_learning_resource_scope_type")
}
enum LearningResourceType {
  ARTICLE
  PODCAST
  VIDEO
}

enum LearningResourceScope {
  JOB_DEFAULT // Ressource par défaut liée au Job (visible pour tous les UserJob du job)
  USER_JOB // Ressource personnalisée pour un UserJob précis
}

enum LearningResourceSource {
  SYSTEM_DEFAULT // créée à la main / seed
  AI_GENERATED // générée par l'IA
  EXTERNAL_LINK // lien externe (YouTube, podcast hébergé ailleurs, etc.)
}

 */
class Resource {
  final String? id;
  final String? jobId;
  final String? userJobId;
  final String? title;
  final String? description;
  final String? url;
  final String? thumbnailUrl;
  final ResourceType? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Author? author;
  final String? content;
  final Map<String, dynamic>? metadata;
  final bool isNew;
  final UserResourceState? userState;
  final int estimatedDuration; // in seconds

  Resource({
    this.id,
    this.jobId,
    this.userJobId,
    this.title,
    this.description,
    this.url,
    this.thumbnailUrl,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.author,
    this.content,
    this.metadata,
    this.isNew = false,
    this.userState,
    this.estimatedDuration = 0,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    final String? id = json['id'] as String?;
    final String? jobId = json['jobId'] as String?;
    final String? userJobId = json['userJobId'] as String?;
    final String? title = json['title'] as String?;
    final String? description = json['description'] as String?;
    final String? url = json['url'] ?? json['mediaUrl'] as String?;
    final String? thumbnailUrl =
        json['thumbnailUrl'] as String? ?? json['thumbnail_url'] as String? ?? json['thumbnail'] as String?;
    final String? typeString = json['type'] as String?;
    final ResourceType type = typeString != null
        ? ResourceType.values.firstWhere(
            (e) => e.name.toUpperCase() == typeString.toUpperCase(),
            orElse: () => ResourceType.article,
          )
        : ResourceType.article;
    final DateTime? createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null;
    final DateTime? updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null;
    final String? content = json['content'] as String?;
    final dynamic metadataJson = json['metadata'];
    final Map<String, dynamic>? metadata = metadataJson is Map ? metadataJson.cast<String, dynamic>() : null;
    final dynamic userStateJson = json['userState'];
    final UserResourceState? userState =
        userStateJson is Map<String, dynamic> ? UserResourceState.fromJson(userStateJson) : null;
    final bool isNew = userState?.openedAt == null && json['source'] != 'SYSTEM_DEFAULT';
    final int estimatedDuration = json['estimatedDuration'] is num
        ? (json['estimatedDuration'] as num).toInt()
        : 5 * 60; // default to 5 minutes if not provided

    return Resource(
      id: id,
      jobId: jobId,
      userJobId: userJobId,
      title: title,
      description: description,
      url: url,
      thumbnailUrl: thumbnailUrl,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt,
      content: content,
      metadata: metadata,
      userState: userState,
      isNew: isNew,
      estimatedDuration: estimatedDuration,
    );
  }

  Resource copyWith({
    String? id,
    String? jobId,
    String? userJobId,
    String? title,
    String? description,
    String? url,
    String? thumbnailUrl,
    ResourceType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    Author? author,
    String? content,
    Map<String, dynamic>? metadata,
    bool? isNew,
    UserResourceState? userState,
    int? estimatedDuration,
  }) {
    if (userState != null) {
      isNew = userState.openedAt == null;
    }
    return Resource(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      userJobId: userJobId ?? this.userJobId,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      isNew: isNew ?? this.isNew,
      userState: userState ?? this.userState,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }

  String? get effectiveThumbnailUrl {
    final metadataThumbnail = metadata?['thumbnailUrl'] ?? metadata?['thumbnail_url'] ?? metadata?['thumbnail'];
    if (metadataThumbnail is String && metadataThumbnail.isNotEmpty) {
      return metadataThumbnail;
    }
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return thumbnailUrl;
    }
    return null;
  }

  ResourceSummary get summary => ResourceSummary(sections: []);

  String get iconPath {
    switch (type) {
      case ResourceType.article:
        return AppIcons.booksPath;
      case ResourceType.podcast:
        return AppIcons.micPath;
      case ResourceType.video:
        return AppIcons.videoPlayerPath;
      default:
        return AppIcons.booksPath;
    }
  }

  Color get borderColor {
    switch (type) {
      case ResourceType.article:
        return const Color.fromRGBO(255, 214, 0, 1); // Yellowish
      case ResourceType.podcast:
        return const Color.fromRGBO(255, 120, 73, 1); // Reddish
      case ResourceType.video:
        return const Color.fromRGBO(39, 245, 152, 1); // Greenish
      default:
        return const Color.fromRGBO(255, 214, 0, 1); // Yellowish
    }
  }

  static empty() {
    return Resource(
      title: 'Sample Resource',
      description: 'This is a sample description for the resource.',
      url: 'https://example.com/resource',
      type: ResourceType.article,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isNew: false,
    );
  }
}
