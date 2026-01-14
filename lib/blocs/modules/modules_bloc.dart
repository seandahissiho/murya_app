import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/module.dart';
import 'package:murya/services/cache.service.dart';

part 'modules_event.dart';
part 'modules_state.dart';

class ModulesBloc extends Bloc<ModulesEvent, ModulesState> {
  final BuildContext context;
  final List<Module> _modules = [];
  final CacheService _cacheService = CacheService();

  static const String _modulesKeyMobile = 'modules_layout_mobile';
  static const String _modulesKeyDesktop = 'modules_layout_desktop';

  late final ProfileBloc profileBloc;
  late final StreamSubscription<ProfileState> _profileSubscription;
  late final JobBloc jobBloc;
  late final StreamSubscription<JobState> _jobSubscription;

  ModulesBloc({required this.context}) : super(ModulesInitial()) {
    on<ModulesEvent>((event, emit) {
      emit(ModulesLoading(modules: state.modules));
    });
    on<InitializeModules>(_onInitializeModules);
    on<LoadModules>(_onLoadModules);
    on<UpdateModule>(_onUpdateModule);
    on<ReorderModules>(_onReorderModules);

    profileBloc = BlocProvider.of<ProfileBloc>(context);
    jobBloc = BlocProvider.of<JobBloc>(context);

    _profileSubscription = profileBloc.stream.listen((state) {
      if (state is ProfileLoaded) {}
    });
    _jobSubscription = jobBloc.stream.listen((state) {
      if (state is UserJobDetailsLoaded && state.userCurrentJob != null) {
        log("ModulesBloc: User has a current job, ensuring job module is present.");
        bool exists = _modules.map((e) => e.id).contains("ressources");
        bool isMobile = DeviceHelper.isMobile(context);
        if (exists == false) {
          for (int i = 0; i < _modules.length; i++) {
            _modules[i] = _modules[i].copyWith(
              index: i,
              boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
            );
          }
          final ressourcesModule = Module(
            id: "ressources",
            index: _modules.length,
            boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
          );
          _modules.add(ressourcesModule);
          add(LoadModules());
        }
      }
    });
  }

  FutureOr<void> _onInitializeModules(InitializeModules event, Emitter<ModulesState> emit) async {
    final cachedModules = await _loadModulesFromCache(event.context);
    if (cachedModules != null && cachedModules.isNotEmpty) {
      _modules
        ..clear()
        ..addAll(cachedModules);
      emit(ModulesLoaded(modules: _modules));
      return;
    }

    _modules
      ..clear()
      ..addAll(_defaultModules(event.context));
    emit(ModulesLoaded(modules: _modules));
    await _persistModules(event.context);
  }

  FutureOr<void> _onLoadModules(LoadModules event, Emitter<ModulesState> emit) {
    if (_modules.isNotEmpty) {
      _modules.sort((a, b) => a.index.compareTo(b.index));
    }
    emit(ModulesLoaded(modules: _modules));
    _persistModules(context);
  }

  FutureOr<void> _onUpdateModule(UpdateModule event, Emitter<ModulesState> emit) {
    final index = _modules.indexWhere((module) => module.id == event.module.id);
    if (index != -1) {
      _modules[index] = event.module;
      // sort by index
      if (_modules.isNotEmpty) {
        _modules.sort((a, b) => a.index.compareTo(b.index));
      }
      emit(ModulesLoaded(modules: _modules));
    } else {
      _modules.add(event.module);
      // sort by index
      if (_modules.isNotEmpty) {
        _modules.sort((a, b) => a.index.compareTo(b.index));
      }
      emit(ModulesLoaded(modules: _modules));
    }
    // save to persistent storage
    // save online
    _persistModules(context);
  }

  FutureOr<void> _onReorderModules(ReorderModules event, Emitter<ModulesState> emit) {
    final list = [...state.modules];
    final moved = list.removeAt(event.from);
    list.insert(event.to, moved);

    // Reassign indices if you rely on a stable `index`
    final reindexed = [for (var i = 0; i < list.length; i++) list[i].copyWith(index: i)];

    // order _modules as well
    _modules
      ..clear()
      ..addAll(reindexed);

    if (_modules.isNotEmpty) {
      _modules.sort((a, b) => a.index.compareTo(b.index));
    }
    emit(ModulesLoaded(modules: _modules));
    _persistModules(context);
  }

  String _storageKeyForContext(BuildContext ctx) {
    return DeviceHelper.isMobile(ctx) ? _modulesKeyMobile : _modulesKeyDesktop;
  }

  List<Module> _defaultModules(BuildContext ctx) {
    final bool isMobile = DeviceHelper.isMobile(ctx);
    return [
      Module(
        id: "job",
        index: 0,
        boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
      ),
      Module(
        id: "ressources",
        index: 1,
        boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
      ),
      Module(
        id: "account",
        index: 2,
        boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
      ),
      // // fake modules for testing
      // Module(
      //   id: "module_1",
      //   index: 3,
      //   boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
      // ),
      // Module(
      //   id: "module_2",
      //   index: 4,
      //   boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
      // ),
      // Module(
      //   id: "module_3",
      //   index: 5,
      //   boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
      // ),
      // Module(
      //   id: "module_4",
      //   index: 6,
      //   boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
      // ),
      // Module(
      //   id: "module_5",
      //   index: 7,
      //   boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
      // ),
    ];
  }

  List<Module> _normalizeModules(List<Module> modules, BuildContext ctx) {
    final defaults = _defaultModules(ctx);
    final Map<String, Module> unique = {};
    for (final module in modules) {
      final id = module.id;
      if (id == null) continue;
      unique[id] = module;
    }
    for (final module in defaults) {
      final id = module.id;
      if (id == null) continue;
      unique.putIfAbsent(id, () => module);
    }
    final ordered = unique.values.toList()..sort((a, b) => a.index.compareTo(b.index));
    return [for (var i = 0; i < ordered.length; i++) ordered[i].copyWith(index: i)];
  }

  Future<List<Module>?> _loadModulesFromCache(BuildContext ctx) async {
    final data = await _cacheService.get(_storageKeyForContext(ctx));
    if (data == null) return null;
    final raw = data['modules'];
    if (raw is! List) return null;
    try {
      final modules = raw.whereType<Map>().map((item) => Module.fromJson(Map<String, dynamic>.from(item))).toList();
      if (modules.isEmpty) return null;
      return _normalizeModules(modules, ctx);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistModules(BuildContext ctx) async {
    await _cacheService.save(
      _storageKeyForContext(ctx),
      {
        'modules': _modules.map((m) => m.toJson()).toList(),
      },
    );
  }
}
