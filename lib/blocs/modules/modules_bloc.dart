import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/models/module.dart';

part 'modules_event.dart';
part 'modules_state.dart';

class ModulesBloc extends Bloc<ModulesEvent, ModulesState> {
  final BuildContext context;
  final List<Module> _modules = [];

  ModulesBloc({required this.context}) : super(ModulesInitial()) {
    on<ModulesEvent>((event, emit) {
      emit(ModulesLoading(modules: state.modules));
    });
    on<InitializeModules>(_onInitializeModules);
    on<LoadModules>(_onLoadModules);
    on<UpdateModule>(_onUpdateModule);
    on<ReorderModules>(_onReorderModules);
  }

  FutureOr<void> _onInitializeModules(InitializeModules event, Emitter<ModulesState> emit) {
    bool isMobile = DeviceHelper.isMobile(event.context);
    // account module
    final Module accountModule = Module(
      id: "account",
      index: 0,
      boxType: AppModuleType.type2_2,
    );
    final Module searchModule = Module(
      id: "search",
      index: 1,
      boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
    );
    final Module statsModule = Module(
      id: "stats",
      index: 2,
      boxType: AppModuleType.type1,
    );
    final Module accountModule2 = Module(
      id: "account-2",
      index: 3,
      boxType: AppModuleType.type2_1,
    );
    final Module searchModule2 = Module(
      id: "search-2",
      index: 4,
      boxType: AppModuleType.type2_1,
    );
    final Module statsModule2 = Module(
      id: "stats-2",
      index: 5,
      boxType: AppModuleType.type2_2,
    );
    final Module accountModule3 = Module(
      id: "account-3",
      index: 6,
      boxType: AppModuleType.type2_1,
    );
    final Module searchModule3 = Module(
      id: "search-3",
      index: 7,
      boxType: AppModuleType.type2_1,
    );
    final Module statsModule3 = Module(
      id: "stats-3",
      index: 8,
      boxType: AppModuleType.type2_2,
    );

    _modules.addAll([
      accountModule,
      searchModule,
      statsModule,
      // statsModule,
      // statsModule,
      // statsModule,
      // accountModule2,
      // searchModule2,
      // statsModule2,
      // accountModule3,
      // searchModule3,
      // statsModule3,
    ]);
    if (_modules.isNotEmpty) {
      _modules.sort((a, b) => a.index.compareTo(b.index));
    }
    emit(ModulesLoaded(modules: _modules));
  }

  FutureOr<void> _onLoadModules(LoadModules event, Emitter<ModulesState> emit) {
    if (_modules.isNotEmpty) {
      _modules.sort((a, b) => a.index.compareTo(b.index));
    }
    emit(ModulesLoaded(modules: _modules));
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
    }
    // save to persistent storage
    // save online
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
  }
}
