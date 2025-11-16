import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:murya/models/resource.dart';

part 'resources_event.dart';
part 'resources_state.dart';

class ResourcesBloc extends Bloc<ResourcesEvent, ResourcesState> {
  ResourcesBloc() : super(ResourcesInitial()) {
    on<ResourcesEvent>((event, emit) {
      emit(ResourcesLoading());
    });
    on<GenerateResource>(_onGenerateResource);
    on<LoadResourceDetails>(_onLoadResourceDetails);
    on<LoadResources>(_onLoadResources);
  }

  FutureOr<void> _onGenerateResource(GenerateResource event, Emitter<ResourcesState> emit) async {}
  FutureOr<void> _onLoadResourceDetails(LoadResourceDetails event, Emitter<ResourcesState> emit) async {}
  FutureOr<void> _onLoadResources(LoadResources event, Emitter<ResourcesState> emit) async {}
}
