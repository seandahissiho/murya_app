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
  String get landing_page_title => 'Home page';

  @override
  String get landing_first_title => 'Journey';

  @override
  String get landing_first_subtitle =>
      'Create your account, explore, and improve. It\'s free with no hidden fees.';

  @override
  String get landing_first_button1 => 'Pilot';

  @override
  String get landing_first_button2 => 'Log in';

  @override
  String get landing_second_title => 'Skills';

  @override
  String get landing_second_subtitle =>
      'Choose your job and get started. Short questions, real progress.';

  @override
  String get landing_second_button => 'Improve';

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
  String get footer_copyright => '2025 Murya SAS';

  @override
  String get search_placeholder => 'Search';

  @override
  String get user_ressources_module_title => 'Resources';

  @override
  String get user_ressources_module_subtitle =>
      'Murya content generation is instant';

  @override
  String get user_ressources_module_button => 'Customize';

  @override
  String searchNoResults(String query) {
    return 'No results found for \"$query\".';
  }

  @override
  String get landingSkillButtonText => 'Improve';

  @override
  String get evaluateSkills => 'Assess skills';

  @override
  String evaluateSkillsAvailableIn(String time) {
    return 'Next assessment - $time';
  }

  @override
  String get skillsDiagramTitle => 'Chart';

  @override
  String get profile_account_title => 'Account';

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
      other: '$count skills',
      one: '1 skill',
      zero: 'No skills',
    );
    return '$_temp0';
  }

  @override
  String get competencyRatingVeryGoodTooltip =>
      'This indicator reflects your progress';

  @override
  String get competencyRatingGoodTooltip =>
      'This indicator reflects your progress';

  @override
  String get competencyRatingAverageTooltip =>
      'This indicator reflects your progress';

  @override
  String get competencyRatingBadTooltip =>
      'This indicator reflects your progress';

  @override
  String get competencyRatingVeryBadTooltip =>
      'This indicator reflects your progress';

  @override
  String get show_more => 'Show more';

  @override
  String get show_less => 'Show less';

  @override
  String discover_job_profile(String jobTitle) {
    return 'Discover the skills profile for the job $jobTitle!';
  }

  @override
  String job_profile_page_title(String jobTitle) {
    return 'Murya - $jobTitle';
  }

  @override
  String get link_copied => 'Link copied to clipboard';

  @override
  String discover_cf_profile(String cfTitle) {
    return 'Discover the skills profile for the skill family $cfTitle!';
  }

  @override
  String get hard_skill => 'Hard skill';

  @override
  String get soft_skill => 'Soft skill';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get expert => 'Expert';

  @override
  String get consult => 'View';

  @override
  String get ranking_per_day => 'Today';

  @override
  String get ranking_per_week => 'This week';

  @override
  String get ranking_per_month => 'This month';

  @override
  String get ranking => 'Leaderboard';

  @override
  String get popup_job_selection_title => 'Choose your job';

  @override
  String get popup_job_selection_technician_title => 'Cybersecurity Technician';

  @override
  String get popup_job_selection_technician_subtitle =>
      'Protect critical infrastructure. Become a highly sought-after expert.';

  @override
  String get popup_job_selection_continue_button => 'Continue';

  @override
  String get popup_job_selection_other_expertise_label =>
      'Aiming for another expertise?';

  @override
  String get popup_job_selection_search_hint =>
      'e.g.: Developer, Product Manager...';

  @override
  String get resourceViewerPageTitle => 'Resource Viewer Page';

  @override
  String get unsupportedResourceType => 'Unsupported resource type';

  @override
  String get videoViewerMissingUrl => 'Video URL is missing';

  @override
  String get videoViewerInvalidUrl => 'Video URL must use http or https';

  @override
  String get videoViewerLoadFailed => 'Unable to load video';

  @override
  String get audioViewerMissingUrl => 'Audio URL is missing';

  @override
  String get audioViewerInvalidUrl => 'Audio URL must use http or https';

  @override
  String get audioViewerLoadFailed => 'Unable to load audio';

  @override
  String get homeScreenTitle => 'Home';

  @override
  String get mainSearchTitle => 'Main Search';

  @override
  String get mediaLibrary => 'Media library';

  @override
  String get summary => 'Summary';

  @override
  String get article => 'Article';

  @override
  String get quiz_ready_to_evaluate => 'Ready to assess yourself?';

  @override
  String get quiz_start_description_1 =>
      'You\'re about to start the Product Manager questionnaire.';

  @override
  String get quiz_start_description_2 =>
      'It includes 10 multiple-choice questions.';

  @override
  String get quiz_start_description_3 =>
      'Your answers will be used to create your personalized resource.';

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
  String get quiz_completed_title => 'Assessment complete!';

  @override
  String get quiz_completed_subtitle =>
      'Well done, your 10 answers have been analyzed!';

  @override
  String get quiz_completed_description =>
      'The skills chart has been updated and you can create the perfect resource to keep improving.';

  @override
  String get quiz_see_my_space => 'Go to my space';

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
  String get popup_validate => 'Confirm';

  @override
  String get popup_unlock_resource_title => 'Unlock your resource?';

  @override
  String get popup_unlock_resource_description =>
      'Use your points to generate your personalized article. Murya\'s AI will instantly adapt it to your answers for the day.';

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
      'We\'re analyzing your 10 answers to write a unique article, perfectly tailored to the skills you need to strengthen.';

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
  String get quiz_daily_performance => 'Your performance today';

  @override
  String get quiz_good_answers => 'Correct answers';

  @override
  String get quiz_answers_to_review => 'Answers to review';

  @override
  String get quiz_reward => 'Reward';

  @override
  String get parcoursPageTitle => 'Journey';

  @override
  String get parcoursTab_profile => 'Profile';

  @override
  String get parcoursTab_objectives => 'Goals';

  @override
  String get parcoursTab_rewards => 'Rewards';

  @override
  String get parcoursTab_settings => 'Settings';

  @override
  String parcoursRanking_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: '0 people',
    );
    return '$_temp0';
  }

  @override
  String get parcoursRanking_header_person => 'Person';

  @override
  String get parcoursRanking_header_experience => 'Experience';

  @override
  String get parcoursRanking_header_answeredQuestions => 'Answered questions';

  @override
  String get parcoursRanking_header_performance => 'Performance';

  @override
  String parcoursRanking_answeredSince(int count, String date) {
    return '$count since $date';
  }

  @override
  String get parcoursRanking_status_pending => 'Pending';

  @override
  String get parcoursRanking_youTag => '(You)';

  @override
  String get parcoursObjective_inProgress => 'Goal in progress';

  @override
  String get parcoursObjective_finalizePositioningPath =>
      'Complete the positioning journey';

  @override
  String get parcoursRewards_possibleTitle => 'Possible rewards';

  @override
  String get parcoursRewards_seeAll => 'See all';

  @override
  String reward_remainingPlaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places left',
      one: '1 place left',
      zero: '0 places left',
    );
    return '$_temp0';
  }

  @override
  String get reward_unlock_cta => 'Unlock';

  @override
  String get rewardKind_cinema => 'Cinema';

  @override
  String get rewardKind_concertHall => 'Concert hall';

  @override
  String get rewardKind_theatre => 'Theater';

  @override
  String get rewardKind_sportsMatch => 'Basketball game';

  @override
  String get rewardKind_themePark => 'Theme park';

  @override
  String get rewardKind_other => 'Other';

  @override
  String get rewardItem_francofoliesLaRochelle =>
      'Les Francofolies de La Rochelle';

  @override
  String get rewardItem_futuroscope => 'Futuroscope';

  @override
  String get rewardItem_cinemaTicket => 'Movie ticket';

  @override
  String get parcoursRecentActivities_title => 'Recent activity';

  @override
  String get inviteFriends_title => 'Invite friends';

  @override
  String inviteFriends_bonus(int amount) {
    return 'Each friend who joins you earns you $amount 💎.';
  }

  @override
  String get inviteFriends_cta => 'Invite';

  @override
  String get common_ok => 'Ok';

  @override
  String get popup_contentNotAvailable_title => 'Demo version';

  @override
  String get popup_contentNotAvailable_body =>
      'This feature is not available in the prototype. It will be unlocked in the full version of Murya.';

  @override
  String get popup_contentNotAvailable_cta => 'Ok, got it';

  @override
  String get authLoading_title => 'Loading...';

  @override
  String get authLoading_message_engineInit => 'Initializing engine...';

  @override
  String get authLoading_message_uiArtifacts => 'Loading UI artifacts...';

  @override
  String get authLoading_message_permissionsCheck => 'Checking permissions...';

  @override
  String get authLoading_message_modulesCompile => 'Compiling modules...';

  @override
  String get authLoading_message_cacheSync => 'Syncing local cache...';

  @override
  String get authLoading_message_profileFetch => 'Fetching user profile...';

  @override
  String get authLoading_message_sessionPrep => 'Preparing session...';

  @override
  String get authLoading_message_renderOptimize => 'Optimizing rendering...';

  @override
  String get authLoading_message_finalize => 'Finalizing...';

  @override
  String authLoading_debugLine(int percent) {
    return 'Loading resources • $percent%';
  }

  @override
  String get chip_new => 'New';

  @override
  String get chip_pending => 'Pending';

  @override
  String get user_firstName_placeholder => 'Firstname';

  @override
  String get user_lastName_placeholder => 'Lastname';

  @override
  String get user_anonymous_placeholder => 'Firstname Lastname';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: 'Day 1 — great start!',
      zero: 'Day 1 — great start!',
    );
    return '$_temp0';
  }

  @override
  String get email_label => 'Email';

  @override
  String get email_invalid_error => 'Invalid email';

  @override
  String get diploma_label => 'Diploma';

  @override
  String get diplomaYear_label => 'Graduation year';

  @override
  String get diplomaSchool_label => 'School';

  @override
  String get saveChanges_button => 'Save';

  @override
  String get editChanges_button => 'Edit';

  @override
  String get search_filter_all => 'All';

  @override
  String get search_filter_job => 'Jobs';

  @override
  String get search_filter_resource => 'Resources';

  @override
  String get search_filter_profile => 'Profiles';
}
