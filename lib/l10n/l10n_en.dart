// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MURYA';

  @override
  String greeting(String name) {
    return 'Hello $name!';
  }

  @override
  String get landing_page_title => 'Landing Page';

  @override
  String get landing_first_title => 'Grow your career';

  @override
  String get landing_first_subtitle =>
      'Create your account, explore and progress. It\'s free with no hidden fees.';

  @override
  String get landing_first_button1 => 'Sign up';

  @override
  String get landing_first_button2 => 'Log in';

  @override
  String get landing_second_title => 'Measure your skills';

  @override
  String get landing_second_subtitle =>
      'Choose your job and get started. Short questions, concrete progress.';

  @override
  String get landing_second_button => 'Discover';

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
  String get user_ressources_module_title => 'Customize your resources';

  @override
  String get user_ressources_module_subtitle =>
      'Murya content generation is instant';

  @override
  String get user_ressources_module_button => 'Collect';

  @override
  String searchNoResults(String query) {
    return 'No results found for \"$query\".';
  }

  @override
  String get evaluateSkills => 'Evaluate Skills';

  @override
  String evaluateSkillsAvailableIn(String time) {
    return 'Next evaluation available in $time';
  }

  @override
  String get skillsDiagramTitle => 'Skills Diagram';

  @override
  String get skillLevel_easy => 'Junior';

  @override
  String get skillLevel_medium => 'Intermediate';

  @override
  String get skillLevel_hard => 'Senior';

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

  @override
  String get ranking_per_day => 'Today';

  @override
  String get ranking_per_week => 'This Week';

  @override
  String get ranking_per_month => 'This Month';

  @override
  String get ranking => 'Ranking';

  @override
  String get popup_job_selection_title => 'Choose your job';

  @override
  String get popup_job_selection_technician_title => 'Cybersecurity Technician';

  @override
  String get popup_job_selection_technician_subtitle =>
      'Protect critical infrastructures. Become a sought-after expert.';

  @override
  String get popup_job_selection_continue_button => 'Continue';

  @override
  String get popup_job_selection_other_expertise_label =>
      'Looking for another expertise?';

  @override
  String get popup_job_selection_search_hint =>
      'Ex: Developer, Product Manager...';

  @override
  String get resourceViewerPageTitle => 'ResourceViewer Page';

  @override
  String get unsupportedResourceType => 'Unsupported resource type';

  @override
  String get homeScreenTitle => 'Home';

  @override
  String get mainSearchTitle => 'Main Search';

  @override
  String get mediaLibrary => 'Media Library';

  @override
  String get summary => 'Summary';

  @override
  String get article => 'Article';

  @override
  String get quiz_ready_to_evaluate => 'Ready to evaluate yourself?';

  @override
  String get quiz_start_description_1 =>
      'You are about to start the questionnaire for the Product Manager job.';

  @override
  String get quiz_start_description_2 =>
      'It consists of 10 multiple-choice questions.';

  @override
  String get quiz_start_description_3 =>
      'Your answers will help create your personalized resource.';

  @override
  String get quiz_start_advice =>
      'Tip: Answer instinctively for a more accurate analysis. It takes less than 5 minutes!';

  @override
  String get quiz_lets_go => 'Let\'s go!';

  @override
  String quiz_question_counter(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get quiz_verify => 'Check';

  @override
  String get quiz_completed_title => 'Evaluation completed!';

  @override
  String get quiz_completed_subtitle =>
      'Well done, your 10 answers have been analyzed!';

  @override
  String get quiz_completed_description =>
      'The skills diagram is updated and you can create the perfect resource to keep progressing.';

  @override
  String get quiz_see_my_space => 'See my space';

  @override
  String get sampleResource => 'Sample Resource';

  @override
  String get resourceLabelSingular_article => 'an article';

  @override
  String get resourceLabelSingular_video => 'a video';

  @override
  String get resourceLabelSingular_podcast => 'a podcast';

  @override
  String get resourceLabelSingular_default => 'a resource';

  @override
  String get popup_validate => 'Validate';

  @override
  String get popup_unlock_resource_title => 'Unlock your resource?';

  @override
  String get popup_unlock_resource_description =>
      'Use your points to generate your personalized article. Murya AI will instantly adapt it to your answers of the day.';

  @override
  String get cost_creation_label => 'Creation cost';

  @override
  String get cost_current_balance_label => 'Your current balance';

  @override
  String get cost_remaining_balance_label =>
      'Your remaining balance (after creation)';

  @override
  String get loading_creating_resource => 'Creating your resource...';

  @override
  String get loading_murya_working => 'Murya is working!';

  @override
  String get loading_analyzing_answers =>
      'We are analyzing your 10 answers to write a unique article, perfectly adapted to the skills you need to strengthen.';

  @override
  String create_resource_button(String resourceLabel) {
    return 'Create $resourceLabel';
  }

  @override
  String get resourcesPageTitle => 'Resources Page';

  @override
  String get page_title_resources => 'Resources';

  @override
  String get section_articles => 'Articles';

  @override
  String get section_videos => 'Videos';

  @override
  String get section_podcasts => 'Podcasts';

  @override
  String get quiz_daily_performance => 'Your daily performance';

  @override
  String get quiz_good_answers => 'Correct answers';

  @override
  String get quiz_answers_to_review => 'Answers to Review';

  @override
  String get quiz_reward => 'Reward';
}
