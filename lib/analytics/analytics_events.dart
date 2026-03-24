import 'package:murya/config/routes.dart';

class AnalyticsEventNames {
  static const screenViewed = 'ui_screen_viewed';
  static const authSubmitClicked = 'ui_auth_submit_clicked';
  static const currentJobSelected = 'ui_current_job_selected';
  static const quizStartClicked = 'ui_quiz_start_clicked';
  static const quizSubmitClicked = 'ui_quiz_submit_clicked';
  static const resourceGenerateClicked = 'ui_resource_generate_clicked';
  static const resourceCollectClicked = 'ui_resource_collect_clicked';
  static const resourceLikeClicked = 'ui_resource_like_clicked';
  static const rewardPurchaseClicked = 'ui_reward_purchase_clicked';
  static const languageChanged = 'ui_language_changed';
  static const apiErrorShown = 'ui_api_error_shown';
}

class AnalyticsScreenNames {
  static const landing = 'landing';
  static const login = 'login';
  static const register = 'register';
  static const dashboard = 'dashboard';
  static const profile = 'profile';
  static const search = 'search';
  static const jobDetails = 'job_details';
  static const jobEvaluation = 'job_evaluation';
  static const resources = 'resources';
  static const resourceViewer = 'resource_viewer';
}

String normalizeAnalyticsRoute(String? route) {
  final trimmed = (route ?? '').trim();
  if (trimmed.isEmpty) {
    return '';
  }

  final uri = Uri.tryParse(trimmed);
  final rawPath = uri?.path.isNotEmpty == true ? uri!.path : trimmed;
  if (rawPath.isEmpty) {
    return '';
  }

  if (rawPath == '/') {
    return AppRoutes.landing;
  }

  if (rawPath.length > 1 && rawPath.endsWith('/')) {
    return rawPath.substring(0, rawPath.length - 1);
  }

  return rawPath;
}

String? resolveAnalyticsScreenName(String route) {
  final normalizedRoute = normalizeAnalyticsRoute(route);
  if (normalizedRoute.isEmpty) {
    return null;
  }

  switch (normalizedRoute) {
    case '/':
    case AppRoutes.landing:
      return AnalyticsScreenNames.landing;
    case AppRoutes.login:
      return AnalyticsScreenNames.login;
    case AppRoutes.register:
      return AnalyticsScreenNames.register;
    case AppRoutes.dashboard:
      return AnalyticsScreenNames.dashboard;
    case AppRoutes.profile:
      return AnalyticsScreenNames.profile;
    case AppRoutes.searchModule:
      return AnalyticsScreenNames.search;
    case AppRoutes.userRessourcesModule:
      return AnalyticsScreenNames.resources;
  }

  if (normalizedRoute.startsWith('/job/') &&
      normalizedRoute.endsWith('/details')) {
    return AnalyticsScreenNames.jobDetails;
  }

  if (normalizedRoute.startsWith('/job/') &&
      normalizedRoute.endsWith('/evaluation')) {
    return AnalyticsScreenNames.jobEvaluation;
  }

  if (normalizedRoute.startsWith('/user-ressources/viewer/')) {
    return AnalyticsScreenNames.resourceViewer;
  }

  return null;
}
