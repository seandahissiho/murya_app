// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NAVY';

  @override
  String greeting(String name) {
    return 'Hello $name!';
  }

  @override
  String get landing_page_title => 'Landing Page';

  @override
  String get landing_first_title => 'Enhance your skills';

  @override
  String get landing_first_subtitle =>
      'Registration and login to Murya are free';

  @override
  String get landing_first_button1 => 'Sign up';

  @override
  String get landing_first_button2 => 'Log in';

  @override
  String get landing_second_title => 'Advance in your profession';

  @override
  String get landing_second_subtitle => 'Browsing the Murya catalog is free';

  @override
  String get landing_second_button => 'Search';

  @override
  String get footer_language_english => '🇬🇧 English';

  @override
  String get footer_language_french => '🇫🇷 Français';

  @override
  String get footer_legal_mentions => 'Legal notice';

  @override
  String get footer_privacy_policy => 'Privacy policy';

  @override
  String get footer_cookie_settings => 'Cookie settings';

  @override
  String get footer_accessibility => 'Accessibility';

  @override
  String get footer_copyright => '© 2025 Murya SAS';

  @override
  String get search_placeholder => 'Search for skills and professions';

  @override
  String get user_stats_module_title => 'User Statistics';

  @override
  String get user_stats_module_subtitle => 'Overview of your activity';

  @override
  String get user_stats_module_button => 'View Details';

  @override
  String searchNoResults(String query) {
    return 'No results found for \"$query\".';
  }

  @override
  String get evaluateSkills => 'Evaluate Skills';

  @override
  String get skillsDiagramTitle => 'Skills Diagram';

  @override
  String get skillLevel_easy => 'Easy';

  @override
  String get skillLevel_medium => 'Medium';

  @override
  String get skillLevel_hard => 'Hard';

  @override
  String get skillLevel_expert => 'Expert';

  @override
  String competencies_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count competencies',
      one: '1 competency',
      zero: 'No competencies',
    );
    return '$_temp0';
  }

  @override
  String get show_more => 'Show more';

  @override
  String get show_less => 'Show less';

  @override
  String discover_job_profile(String jobTitle) {
    return 'Discover the skills profile for the $jobTitle job!';
  }

  @override
  String job_profile_page_title(String jobTitle) {
    return 'Murya - Skills Profile: $jobTitle';
  }

  @override
  String get link_copied => 'Link copied to clipboard';

  @override
  String discover_cf_profile(String cfTitle) {
    return 'Discover the skills profile for the $cfTitle competency family!';
  }

  @override
  String get hard_skill => 'Hard Skill';

  @override
  String get soft_skill => 'Soft Skill';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get expert => 'Expert';

  @override
  String get consult => 'Consult';
}
