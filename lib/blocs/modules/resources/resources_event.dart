part of 'resources_bloc.dart';

@immutable
sealed class ResourcesEvent {}

final class GenerateResource extends ResourcesEvent {
  final ResourceType type;
  final String userJobId;

  GenerateResource({required this.type, required this.userJobId});
}

final class LoadResources extends ResourcesEvent {
  final String? userJobId;

  LoadResources({this.userJobId});
}

final class LoadResourceDetails extends ResourcesEvent {
  final String resourceId;

  LoadResourceDetails({required this.resourceId});
}

final class OpenResource extends ResourcesEvent {
  final String resourceId;

  OpenResource({required this.resourceId});
}

final class ReadResource extends ResourcesEvent {
  final String resourceId;
  final double? progress;

  ReadResource({required this.resourceId, this.progress});
}

final class LikeResource extends ResourcesEvent {
  final String resourceId;
  final bool like;

  LikeResource({required this.resourceId, required this.like});
}
