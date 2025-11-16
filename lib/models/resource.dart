enum ResourceType { article, podcast, video }

class Author {
  final String? id;
  final String? name;
  final String? profileUrl;

  Author({this.id, this.name, this.profileUrl});
}

class Resource {
  final String? id;
  final String? title;
  final String? description;
  final String? url;
  final ResourceType? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Author? author;

  Resource({
    this.id,
    this.title,
    this.description,
    this.url,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.author,
  });

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
