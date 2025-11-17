enum ResourceType { article, podcast, video }

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
  final ResourceType? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Author? author;
  final String? content;

  Resource({
    this.id,
    this.jobId,
    this.userJobId,
    this.title,
    this.description,
    this.url,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.author,
    this.content,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    final String? id = json['id'] as String?;
    final String? jobId = json['jobId'] as String?;
    final String? userJobId = json['userJobId'] as String?;
    final String? title = json['title'] as String?;
    final String? description = json['description'] as String?;
    final String? url = json['url'] as String?;
    final ResourceType? type = ResourceType.article;
    final DateTime? createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null;
    final DateTime? updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null;
    final String? content = json['content'] as String?;

    return Resource(
      id: id,
      jobId: jobId,
      userJobId: userJobId,
      title: title,
      description: description,
      url: url,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt,
      content: content,
    );
  }

  ResourceSummary get summary => ResourceSummary(sections: []);

  static empty() {
    return Resource(
      title: 'Sample Resource',
      description: 'This is a sample description for the resource.',
      url: 'https://example.com/resource',
      type: ResourceType.article,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
