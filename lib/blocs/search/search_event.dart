part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  final BuildContext context;
  final int limit;
  final bool includeTotal;
  final List<String> sections;

  SearchQueryChanged({
    required this.query,
    required this.context,
    this.limit = 10,
    this.includeTotal = true,
    this.sections = const ['jobs', 'jobFamilies', 'learningResources', 'users'],
  });
}

class SearchReset extends SearchEvent {}
