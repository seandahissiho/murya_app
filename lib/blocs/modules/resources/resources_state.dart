part of 'resources_bloc.dart';

@immutable
sealed class ResourcesState {}

final class ResourcesInitial extends ResourcesState {}

final class ResourcesLoading extends ResourcesState {}

final class ResourcesLoaded extends ResourcesState {
  final List<Resource> resources;

  ResourcesLoaded({required this.resources});
}

final class ResourceDetailsLoaded extends ResourcesState {
  final Resource resource;

  ResourceDetailsLoaded({required this.resource});
}
