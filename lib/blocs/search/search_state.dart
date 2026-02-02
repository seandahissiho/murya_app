part of 'search_bloc.dart';

@immutable
abstract class SearchState {
  final SearchResponse response;

  const SearchState({this.response = SearchResponse.zero});
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  const SearchLoaded(SearchResponse response) : super(response: response);
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message, super.response});
}
