import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/repositories/resources.repository.dart';

part 'resources_event.dart';
part 'resources_state.dart';

class ResourcesBloc extends Bloc<ResourcesEvent, ResourcesState> {
  late final JobBloc jobBloc;
  late final StreamSubscription<JobState> _jobSubscription;
  late final AuthenticationBloc _authenticationBloc;
  late final StreamSubscription<AuthenticationState> _authSubscription;

  final List<Resource> _articles = [
    Resource.empty(),
    Resource.empty(),
  ];
  final List<Resource> _videos = [
    Resource.empty(),
    Resource.empty(),
  ];
  final List<Resource> _podcasts = [
    Resource.empty(),
    Resource.empty(),
  ];

  List<Resource> get articles => _articles;

  List<Resource> get videos => _videos;

  List<Resource> get podcasts => _podcasts;

  late final ResourcesRepository resourceRepository;
  late final ProfileBloc profileBloc;

  ResourcesBloc({required BuildContext context}) : super(ResourcesInitial()) {
    on<ResourcesEvent>((event, emit) {
      emit(ResourcesLoading());
    });
    on<GenerateResource>(_onGenerateResource);
    on<LoadResourceDetails>(_onLoadResourceDetails);
    on<LoadResources>(_onLoadResources);

    resourceRepository = RepositoryProvider.of<ResourcesRepository>(context);
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    jobBloc = BlocProvider.of<JobBloc>(context);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    _jobSubscription = jobBloc.stream.listen((state) {
      if (state is JobDetailsLoaded) {
        final userJob = state.userCurrentJob;
        if (userJob != null) {
          add(LoadResources(userJobId: userJob.id));
        }
      }
    });
    _authSubscription = _authenticationBloc.stream.listen((state) async {
      if (state is Authenticated) {
        await Future.delayed(const Duration(milliseconds: 500));
        final userJob = jobBloc.state.userCurrentJob;
        if (userJob != null) {
          add(LoadResources(userJobId: userJob.id));
        }
      }
    });
  }

  FutureOr<void> _onGenerateResource(GenerateResource event, Emitter<ResourcesState> emit) async {
    final result = await resourceRepository.generateResource(type: event.type, userJobId: event.userJobId);
    if (result.isError) {
      // Handle error (e.g., emit an error state or log the error)
      return;
    }
    final resource = result.data!;
    _articles.insert(0, resource);
    emit(ResourceDetailsLoaded(resource: resource));
    profileBloc.add(ProfileLoadEvent());
  }

  FutureOr<void> _onLoadResourceDetails(LoadResourceDetails event, Emitter<ResourcesState> emit) async {}

  FutureOr<void> _onLoadResources(LoadResources event, Emitter<ResourcesState> emit) async {
    final userJobId = event.userJobId;
    if (userJobId == null || userJobId.isEmpty) {
      return;
    }

    final result = await resourceRepository.fetchResources(userJobId);

    if (result.isError) {
      // Handle error
      return;
    }

    final resources = result.data!;

    _articles.clear();
    _videos.clear();
    _podcasts.clear();

    for (var resource in resources) {
      switch (resource.type) {
        case ResourceType.article:
          _articles.add(resource);
          break;
        case ResourceType.video:
          _videos.add(resource);
          break;
        case ResourceType.podcast:
          _podcasts.add(resource);
          break;
        default:
          _articles.add(resource);
      }
    }
    emit(ResourcesLoaded(resources: resources));
  }
}
