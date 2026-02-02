import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/models/search_response.dart';
import 'package:murya/repositories/search.repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final BuildContext context;
  final SearchRepository _searchRepository = SearchRepository();

  SearchBloc({required this.context}) : super(SearchInitial()) {
    on<SearchEvent>((event, emit) {
      emit(SearchLoading());
    });
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchReset>(_onSearchReset);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final cachedResult = await _searchRepository.searchCached(
      query: event.query,
      limit: event.limit,
      includeTotal: event.includeTotal,
      sections: event.sections,
    );
    if (cachedResult.data != null) {
      emit(SearchLoaded(cachedResult.data!));
      log("SearchBloc: Emitted cached result for query '${event.query}'");
    }

    if (!context.mounted) return;

    final result = await _searchRepository.search(
      query: event.query,
      limit: event.limit,
      includeTotal: event.includeTotal,
      sections: event.sections,
      context: event.context,
    );

    if (result.isError) {
      emit(SearchError(message: result.error ?? "Une erreur est survenue", response: state.response));
    } else {
      if (result.data != null) {
        emit(SearchLoaded(result.data!));
      } else {
        emit(SearchInitial());
      }
    }
  }

  void _onSearchReset(SearchReset event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
