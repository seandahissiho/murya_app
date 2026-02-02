import 'package:murya/models/resource.dart';

class SearchResponse {
  final String query;
  final int tookMs;
  final SearchSections sections;
  final SearchErrors errors;

  static const zero = SearchResponse(
    query: '',
    tookMs: 0,
    sections: SearchSections.zero,
    errors: SearchErrors.zero,
  );

  const SearchResponse({
    required this.query,
    required this.tookMs,
    required this.sections,
    required this.errors,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      query: json['query'] as String? ?? '',
      tookMs: json['took_ms'] as int? ?? 0,
      sections: SearchSections.fromJson(json['sections'] as Map<String, dynamic>? ?? {}),
      errors: SearchErrors.fromJson(json['errors'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SearchSections {
  final SearchSection jobs;
  final SearchSection jobFamilies;
  final SearchSection learningResources;
  final SearchSection users;

  static const zero = SearchSections(
    jobs: SearchSection(items: []),
    jobFamilies: SearchSection(items: []),
    learningResources: SearchSection(items: []),
    users: SearchSection(items: []),
  );

  const SearchSections({
    required this.jobs,
    required this.jobFamilies,
    required this.learningResources,
    required this.users,
  });

  factory SearchSections.fromJson(Map<String, dynamic> json) {
    return SearchSections(
      jobs: SearchSection.fromJson(json['jobs'] as Map<String, dynamic>? ?? {}),
      jobFamilies: SearchSection.fromJson(json['jobFamilies'] as Map<String, dynamic>? ?? {}),
      learningResources: SearchSection.fromJson(json['learningResources'] as Map<String, dynamic>? ?? {}),
      users: SearchSection.fromJson(json['users'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SearchSection {
  final List<SearchItem> items;
  final String? nextCursor;
  final int? total;

  const SearchSection({
    required this.items,
    this.nextCursor,
    this.total,
  });

  factory SearchSection.fromJson(Map<String, dynamic> json) {
    return SearchSection(
      items:
          (json['items'] as List<dynamic>?)?.map((e) => SearchItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      nextCursor: json['next_cursor'] as String?,
      total: json['total'] as int?,
    );
  }
}

class SearchItem {
  final String type;
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? icon;
  final double? score;
  final DateTime? createdAt;

  SearchItem({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.icon,
    this.score,
    this.createdAt,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      type: json['type'] as String? ?? '',
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String?,
      icon: json['icon'] as String?,
      score: (json['score'] as num?)?.toDouble() ?? (json['highlights'] != null ? 1.0 : null), // Fallback if needed
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }

  Resource toResource() {
    return Resource(
      id: id,
      title: title,
      createdAt: createdAt,
      type: ResourceTypeX.fromJson(subtitle),
    );
  }
}

class SearchErrors {
  final String? jobs;
  final String? jobFamilies;
  final String? learningResources;
  final String? users;

  static const zero = SearchErrors(
    jobs: null,
    jobFamilies: null,
    learningResources: null,
    users: null,
  );

  const SearchErrors({
    this.jobs,
    this.jobFamilies,
    this.learningResources,
    this.users,
  });

  factory SearchErrors.fromJson(Map<String, dynamic> json) {
    return SearchErrors(
      jobs: json['jobs'] as String?,
      jobFamilies: json['jobFamilies'] as String?,
      learningResources: json['learningResources'] as String?,
      users: json['users'] as String?,
    );
  }
}
