part of 'resources_bloc.dart';

@immutable
sealed class ResourcesEvent {}

final class GenerateResource extends ResourcesEvent {
  final ResourceType type;

  GenerateResource({required this.type});
}

final class LoadResources extends ResourcesEvent {}

final class LoadResourceDetails extends ResourcesEvent {
  final String resourceId;

  LoadResourceDetails({required this.resourceId});
}
