import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/landing_module.dart';
import 'package:murya/models/module.dart';
import 'package:murya/repositories/modules.repository.dart';
import 'package:murya/services/cache.service.dart';

part 'modules_event.dart';
part 'modules_state.dart';

class ModulesBloc extends Bloc<ModulesEvent, ModulesState> {
  final BuildContext context;
  final List<Module> _modules = [];
  final List<Module> _catalogModules = [];
  final List<LandingEvent> _auditEvents = [];
  final CacheService _cacheService = CacheService();

  static const String _modulesKeyMobile = 'modules_layout_mobile';
  static const String _modulesKeyDesktop = 'modules_layout_desktop';
  static const String _catalogKey = 'modules_catalog';
  static const String _catalogMetaKey = 'modules_catalog_meta';
  static const String _landingKeyPrefix = 'landing_modules_';
  static const String _auditKeyPrefix = 'landing_audit_';

  late final ModulesRepository modulesRepository;
  late final NotificationBloc notificationBloc;
  late final AuthenticationBloc authBloc;
  late final ProfileBloc profileBloc;
  late final StreamSubscription<ProfileState> _profileSubscription;
  late final StreamSubscription<AuthenticationState> _authSubscription;

  String? _currentUserId;
  bool _isLoadingLanding = false;
  bool _isLoadingCatalog = false;
  bool _isLoadingAudit = false;
  DateTime? _catalogLastRefresh;
  static const Duration _catalogRefreshTtl = Duration(hours: 1);

  ModulesBloc({required this.context}) : super(ModulesInitial()) {
    on<InitializeModules>(_onInitializeModules);
    on<LoadModules>(_onLoadModules);
    on<LoadLandingModules>(_onLoadLandingModules);
    on<LoadCatalogModules>(_onLoadCatalogModules);
    on<LoadLandingAudit>(_onLoadLandingAudit);
    on<UpdateModule>(_onUpdateModule);
    on<ReorderModules>(_onReorderModules);
    on<AddLandingModule>(_onAddLandingModule);
    on<RemoveLandingModule>(_onRemoveLandingModule);
    on<ResetModules>(_onResetModules);

    profileBloc = BlocProvider.of<ProfileBloc>(context);
    authBloc = BlocProvider.of<AuthenticationBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    modulesRepository = RepositoryProvider.of<ModulesRepository>(context);

    _profileSubscription = profileBloc.stream.listen((state) {
      if (state is ProfileLoaded) {
        add(LoadLandingModules());
      }
    });

    _authSubscription = authBloc.stream.listen((state) {
      if (state is Authenticated) {
        add(LoadLandingModules(force: true));
      } else if (state is Unauthenticated) {
        add(ResetModules());
      }
    });
  }

  FutureOr<void> _onInitializeModules(InitializeModules event, Emitter<ModulesState> emit) async {
    final cachedModules = await _loadModulesFromCache(event.context);
    if (cachedModules != null && cachedModules.isNotEmpty) {
      _modules
        ..clear()
        ..addAll(cachedModules);
      _emitState(emit: emit);
    } else {
      _modules
        ..clear()
        ..addAll(_defaultModules(event.context));
      _emitState(emit: emit);
      await _persistModules(event.context);
    }

    add(LoadLandingModules());
  }

  FutureOr<void> _onResetModules(ResetModules event, Emitter<ModulesState> emit) async {
    _currentUserId = null;
    _auditEvents.clear();
    _catalogLastRefresh = null;
    _modules
      ..clear()
      ..addAll(_defaultModules(context));
    _emitState(emit: emit);
    await _persistModules(context);
  }

  FutureOr<void> _onLoadModules(LoadModules event, Emitter<ModulesState> emit) {
    if (_modules.isNotEmpty) {
      _modules.sort((a, b) => a.index.compareTo(b.index));
    }
    _emitState(emit: emit);
    _persistModules(context);
  }

  FutureOr<void> _onLoadLandingModules(LoadLandingModules event, Emitter<ModulesState> emit) async {
    if (_isLoadingLanding) return;
    final userId = _userId();
    if (userId == null) {
      if (_modules.isEmpty) {
        _modules
          ..clear()
          ..addAll(_defaultModules(context));
        _emitState(emit: emit);
      }
      return;
    }
    if (!event.force && _currentUserId == userId && _modules.isNotEmpty) {
      return;
    }

    final cachedLanding = await _loadLandingModulesFromCache(userId);
    if (cachedLanding != null && cachedLanding.isNotEmpty) {
      await _preloadCatalogFromCache(emit);
      _applyLandingModules(cachedLanding, emit);
    }

    _isLoadingLanding = true;
    _emitState(emit: emit, loading: true);

    await _ensureCatalogLoaded(emit, forceRefresh: event.force);

    final landingResult = await modulesRepository.getLandingModules(userId);
    if (landingResult.isError) {
      _handleRepositoryError(landingResult.error);
      _isLoadingLanding = false;
      _emitState(emit: emit);
      return;
    }

    final landingModules = landingResult.data ?? [];
    await _persistLandingModulesCache(userId, landingModules);
    if (landingModules.isEmpty) {
      _modules
        ..clear()
        ..addAll(_defaultModules(context));
      _isLoadingLanding = false;
      _emitState(emit: emit);
      await _persistModules(context);
      return;
    }

    _applyLandingModules(landingModules, emit);
    _currentUserId = userId;
    _isLoadingLanding = false;
    _emitState(emit: emit);
    await _persistModules(context);
  }

  Future<void> _onLoadCatalogModules(LoadCatalogModules event, Emitter<ModulesState> emit) async {
    final cachedCatalog = await _loadCatalogFromCache();
    if (cachedCatalog != null && cachedCatalog.isNotEmpty) {
      _catalogModules
        ..clear()
        ..addAll(cachedCatalog);
      _emitState(emit: emit);
    }
    await _refreshCatalogFromApi(emit, showLoading: true, force: event.force);
  }

  Future<void> _onLoadLandingAudit(LoadLandingAudit event, Emitter<ModulesState> emit) async {
    if (_isLoadingAudit) return;
    final userId = _userId();
    if (userId == null) {
      _auditEvents.clear();
      _emitState(emit: emit);
      return;
    }

    final cachedAudit = await _loadAuditFromCache(userId);
    if (cachedAudit != null && cachedAudit.isNotEmpty) {
      _auditEvents
        ..clear()
        ..addAll(cachedAudit);
      _emitState(emit: emit);
    }

    _isLoadingAudit = true;
    _emitState(emit: emit, auditLoading: true);

    final result = await modulesRepository.getLandingAudit(userId, since: event.since);
    if (result.isError) {
      _handleRepositoryError(result.error);
      _isLoadingAudit = false;
      _emitState(emit: emit);
      return;
    }
    _auditEvents
      ..clear()
      ..addAll(result.data ?? []);
    await _persistAuditCache(userId);
    _isLoadingAudit = false;
    _emitState(emit: emit);
  }

  FutureOr<void> _onUpdateModule(UpdateModule event, Emitter<ModulesState> emit) {
    final index = _modules.indexWhere((module) => module.id == event.module.id);
    if (index != -1) {
      final existing = _modules[index];
      _modules[index] = existing.copyWith(
        boxType: event.module.boxType,
        index: event.module.index,
      );
    } else {
      _modules.add(event.module);
    }
    if (_modules.isNotEmpty) {
      _modules.sort((a, b) => a.index.compareTo(b.index));
    }
    _emitState(emit: emit);
    _persistModules(context);
  }

  FutureOr<void> _onReorderModules(ReorderModules event, Emitter<ModulesState> emit) async {
    final list = [...state.modules];
    final moved = list.removeAt(event.from);
    list.insert(event.to, moved);

    final reindexed = [for (var i = 0; i < list.length; i++) list[i].copyWith(index: i)];

    _modules
      ..clear()
      ..addAll(reindexed);

    _emitState(emit: emit);
    await _persistModules(context);

    final userId = _userId();
    if (userId == null) {
      return;
    }

    final List<Map<String, dynamic>> orders = [];
    for (var i = 0; i < _modules.length; i++) {
      final moduleId = _modules[i].id;
      if (moduleId == null) continue;
      orders.add({
        'moduleId': moduleId,
        'order': i,
      });
    }
    final result = await modulesRepository.reorderLandingModules(userId, orders);
    if (result.isError) {
      _handleRepositoryError(result.error);
      add(LoadLandingModules(force: true));
    }
  }

  Future<void> _onAddLandingModule(AddLandingModule event, Emitter<ModulesState> emit) async {
    final userId = _userId();
    if (userId == null) {
      _handleRepositoryError(ModulesRepository.errorUnauthorized);
      return;
    }
    final result = await modulesRepository.addLandingModule(userId, event.moduleId);
    if (result.isError) {
      _handleRepositoryError(result.error);
      return;
    }
    add(LoadLandingModules(force: true));
  }

  Future<void> _onRemoveLandingModule(RemoveLandingModule event, Emitter<ModulesState> emit) async {
    final userId = _userId();
    if (userId == null) {
      _handleRepositoryError(ModulesRepository.errorUnauthorized);
      return;
    }
    final result = await modulesRepository.removeLandingModule(userId, event.moduleId);
    if (result.isError) {
      _handleRepositoryError(result.error);
      return;
    }
    add(LoadLandingModules(force: true));
  }

  Future<void> _ensureCatalogLoaded(Emitter<ModulesState> emit, {bool forceRefresh = false}) async {
    if (_catalogModules.isNotEmpty) {
      await _refreshCatalogFromApi(emit, showLoading: false, force: forceRefresh);
      return;
    }
    final cachedCatalog = await _loadCatalogFromCache();
    if (cachedCatalog != null && cachedCatalog.isNotEmpty) {
      _catalogModules
        ..clear()
        ..addAll(cachedCatalog);
      _emitState(emit: emit);
    }
    await _refreshCatalogFromApi(
      emit,
      showLoading: cachedCatalog == null || cachedCatalog.isEmpty,
      force: forceRefresh,
    );
  }

  Future<void> _preloadCatalogFromCache(Emitter<ModulesState> emit) async {
    if (_catalogModules.isNotEmpty) return;
    final cachedCatalog = await _loadCatalogFromCache();
    if (cachedCatalog == null || cachedCatalog.isEmpty) return;
    _catalogModules
      ..clear()
      ..addAll(cachedCatalog);
    _emitState(emit: emit);
  }

  Future<void> _refreshCatalogFromApi(Emitter<ModulesState> emit,
      {required bool showLoading, bool force = false}) async {
    if (!force && _catalogModules.isNotEmpty && _isCatalogFresh()) {
      return;
    }
    if (_isLoadingCatalog) return;
    _isLoadingCatalog = true;
    if (showLoading) {
      _emitState(emit: emit, catalogLoading: true);
    }
    final result = await modulesRepository.getModules();
    if (result.isError) {
      _handleRepositoryError(result.error);
      _isLoadingCatalog = false;
      _emitState(emit: emit, catalogLoading: false);
      return;
    }
    _catalogModules
      ..clear()
      ..addAll(result.data ?? []);
    await _persistCatalogCache();
    _isLoadingCatalog = false;
    _emitState(emit: emit, catalogLoading: false);
  }

  String? _userId() {
    final id = profileBloc.state.user.id;
    if (id.isNotEmptyOrNull) {
      return id;
    }
    return null;
  }

  void _emitState({required Emitter<ModulesState> emit, bool? loading, bool? catalogLoading, bool? auditLoading}) {
    final resolvedLoading = loading ?? _isLoadingLanding;
    final resolvedCatalogLoading = catalogLoading ?? _isLoadingCatalog;
    final resolvedAuditLoading = auditLoading ?? _isLoadingAudit;
    if (resolvedLoading || resolvedCatalogLoading || resolvedAuditLoading) {
      emit(ModulesLoading(
        modules: _modules,
        catalogModules: _catalogModules,
        auditEvents: _auditEvents,
        loading: resolvedLoading,
        catalogLoading: resolvedCatalogLoading,
        auditLoading: resolvedAuditLoading,
      ));
      return;
    }
    emit(ModulesLoaded(
      modules: _modules,
      catalogModules: _catalogModules,
      auditEvents: _auditEvents,
      isLoading: _isLoadingLanding,
      isCatalogLoading: _isLoadingCatalog,
      isAuditLoading: _isLoadingAudit,
    ));
  }

  void _handleRepositoryError(String? errorKey) {
    switch (errorKey) {
      case ModulesRepository.errorUnauthorized:
        notificationBloc.add(ErrorNotificationEvent(message: 'Veuillez vous reconnecter.'));
        authBloc.add(SignOutEvent());
        break;
      case ModulesRepository.errorModuleUnavailable:
        notificationBloc.add(ErrorNotificationEvent(message: 'Module indisponible'));
        break;
      case ModulesRepository.errorDefaultRequired:
        notificationBloc.add(ErrorNotificationEvent(message: 'Ce module est obligatoire'));
        break;
      case ModulesRepository.errorNotFound:
        notificationBloc.add(ErrorNotificationEvent(message: 'Introuvable'));
        break;
      case ModulesRepository.errorAlreadyAdded:
        notificationBloc.add(ErrorNotificationEvent(message: 'Deja ajoute'));
        break;
      default:
        notificationBloc.add(ErrorNotificationEvent(message: 'Une erreur est survenue'));
    }
  }

  String _storageKeyForContext(BuildContext ctx) {
    return DeviceHelper.isMobile(ctx) ? _modulesKeyMobile : _modulesKeyDesktop;
  }

  List<Module> _defaultModules(BuildContext ctx) {
    final bool isMobile = DeviceHelper.isMobile(ctx);
    return [
      Module(
        id: "daily-quiz",
        index: 0,
        boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
        defaultOnLanding: true,
      ),
      Module(
        id: "learning-resources",
        index: 1,
        boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
        defaultOnLanding: true,
      ),
      Module(
        id: "leaderboard",
        index: 2,
        boxType: isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1,
        defaultOnLanding: true,
      ),
    ];
  }

  Future<List<Module>?> _loadModulesFromCache(BuildContext ctx) async {
    final data = await _cacheService.get(_storageKeyForContext(ctx));
    if (data == null) return null;
    final raw = data['modules'];
    if (raw is! List) return null;
    try {
      final modules = raw.whereType<Map>().map((item) => Module.fromJson(Map<String, dynamic>.from(item))).toList();
      if (modules.isEmpty) return null;
      return modules;
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

  Future<List<Module>?> _loadCatalogFromCache() async {
    await _loadCatalogMetaFromCache();
    final data = await _cacheService.get(_catalogKey);
    if (data == null) return null;
    final raw = data['modules'];
    if (raw is! List) return null;
    try {
      final modules = raw.whereType<Map>().map((item) => Module.fromApiJson(Map<String, dynamic>.from(item))).toList();
      if (modules.isEmpty) return null;
      return modules;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistCatalogCache() async {
    final now = DateTime.now();
    _catalogLastRefresh = now;
    await _cacheService.save(
      _catalogKey,
      {
        'modules': _catalogModules.map((module) => module.toApiJson()).toList(),
      },
    );
    await _cacheService.save(
      _catalogMetaKey,
      {
        'lastFetched': now.toIso8601String(),
      },
    );
  }

  Future<void> _loadCatalogMetaFromCache() async {
    if (_catalogLastRefresh != null) return;
    final data = await _cacheService.get(_catalogMetaKey);
    if (data == null) return;
    final raw = data['lastFetched'];
    if (raw is! String) return;
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      _catalogLastRefresh = parsed;
    }
  }

  bool _isCatalogFresh() {
    final lastRefresh = _catalogLastRefresh;
    if (lastRefresh == null) return false;
    return DateTime.now().difference(lastRefresh) < _catalogRefreshTtl;
  }

  Future<List<LandingModule>?> _loadLandingModulesFromCache(String userId) async {
    final data = await _cacheService.get('$_landingKeyPrefix$userId');
    if (data == null) return null;
    final raw = data['modules'];
    if (raw is! List) return null;
    try {
      final modules =
          raw.whereType<Map>().map((item) => LandingModule.fromJson(Map<String, dynamic>.from(item))).toList();
      if (modules.isEmpty) return null;
      return modules;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistLandingModulesCache(String userId, List<LandingModule> modules) async {
    await _cacheService.save(
      '$_landingKeyPrefix$userId',
      {
        'modules': modules.map((module) => module.toJson()).toList(),
      },
    );
  }

  Future<List<LandingEvent>?> _loadAuditFromCache(String userId) async {
    final data = await _cacheService.get('$_auditKeyPrefix$userId');
    if (data == null) return null;
    final raw = data['events'];
    if (raw is! List) return null;
    try {
      final events =
          raw.whereType<Map>().map((item) => LandingEvent.fromJson(Map<String, dynamic>.from(item))).toList();
      if (events.isEmpty) return null;
      return events;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistAuditCache(String userId) async {
    await _cacheService.save(
      '$_auditKeyPrefix$userId',
      {
        'events': _auditEvents.map((event) => event.toJson()).toList(),
      },
    );
  }

  void _applyLandingModules(List<LandingModule> landingModules, Emitter<ModulesState> emit) {
    final Map<String, Module> catalogById = {
      for (final module in _catalogModules)
        if (module.id != null) module.id!: module,
    };
    final Map<String, Module> layoutById = {
      for (final module in _modules)
        if (module.id != null) module.id!: module,
    };
    final bool isMobile = DeviceHelper.isMobile(context);
    final List<Module> resolved = [];
    final AppModuleType fallbackBoxType = isMobile ? AppModuleType.type2_2 : AppModuleType.type2_1;
    for (final entry in landingModules) {
      final moduleId = entry.moduleId;
      if (moduleId.isEmpty) continue;
      final catalogModule = catalogById[moduleId];
      final layout = layoutById[moduleId];
      final Module base = catalogModule ??
          layout ??
          Module(
            id: moduleId,
            index: entry.order,
            boxType: fallbackBoxType,
          );
      resolved.add(
        base.copyWith(
          id: moduleId,
          index: entry.order,
          boxType: layout?.boxType ?? fallbackBoxType,
        ),
      );
    }
    resolved.sort((a, b) => a.index.compareTo(b.index));
    _modules
      ..clear()
      ..addAll(resolved);
    _emitState(emit: emit);
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    _authSubscription.cancel();
    return super.close();
  }
}
