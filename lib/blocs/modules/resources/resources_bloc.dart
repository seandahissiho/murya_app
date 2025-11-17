import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/repositories/resources.repository.dart';

part 'resources_event.dart';
part 'resources_state.dart';

class ResourcesBloc extends Bloc<ResourcesEvent, ResourcesState> {
  late final ResourcesRepository resourceRepository;

  ResourcesBloc({required BuildContext context}) : super(ResourcesInitial()) {
    on<ResourcesEvent>((event, emit) {
      emit(ResourcesLoading());
    });
    on<GenerateResource>(_onGenerateResource);
    on<LoadResourceDetails>(_onLoadResourceDetails);
    on<LoadResources>(_onLoadResources);

    resourceRepository = RepositoryProvider.of<ResourcesRepository>(context);
  }

  FutureOr<void> _onGenerateResource(GenerateResource event, Emitter<ResourcesState> emit) async {
    final result = await resourceRepository.generateResource(type: event.type, userJobId: event.userJobId);
    if (result.isError) {
      // Handle error (e.g., emit an error state or log the error)
      return;
    }
    final resource = result.data!;
    emit(ResourceDetailsLoaded(resource: resource));
  }

  FutureOr<void> _onLoadResourceDetails(LoadResourceDetails event, Emitter<ResourcesState> emit) async {}
  FutureOr<void> _onLoadResources(LoadResources event, Emitter<ResourcesState> emit) async {}
}
