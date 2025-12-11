// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MURYA';

  @override
  String greeting(String name) {
    return 'Bonjour $name!';
  }

  @override
  String get landing_page_title => 'Page d’accueil';

  @override
  String get landing_first_title => 'Développez votre carrière';

  @override
  String get landing_first_subtitle =>
      'Créez votre compte, explorez et progressez. C\'est gratuit et sans frais cachés.';

  @override
  String get landing_first_button1 => 'Inscription';

  @override
  String get landing_first_button2 => 'Connexion';

  @override
  String get landing_second_title => 'Mesurez vos compétences';

  @override
  String get landing_second_subtitle =>
      'Choisissez votre métier et lancez-vous. Des questions courtes, des progrès concrets.';

  @override
  String get landing_second_button => 'Découvrir';

  @override
  String get footer_language_english => '🇬🇧 English';

  @override
  String get footer_language_french => '🇫🇷 Français';

  @override
  String get footer_legal_mentions => 'Mentions légales';

  @override
  String get footer_privacy_policy => 'Règles de confidentialité';

  @override
  String get footer_cookie_settings => 'Paramètres des cookies';

  @override
  String get footer_accessibility => 'Accessibilité';

  @override
  String get footer_copyright => '2025 Murya SAS';

  @override
  String get search_placeholder => 'Rechercher des compétences et des métiers';

  @override
  String get user_ressources_module_title => 'Personnalisez vos ressources';

  @override
  String get user_ressources_module_subtitle =>
      'La génération des contenus de Murya est instantanée';

  @override
  String get user_ressources_module_button => 'Créer';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat trouvé pour \"$query\".';
  }

  @override
  String get evaluateSkills => 'Évaluer les compétences';

  @override
  String evaluateSkillsAvailableIn(String time) {
    return 'Prochaine évaluation - $time';
  }

  @override
  String get skillsDiagramTitle => 'Diagramme des compétences';

  @override
  String get skillLevel_easy => 'Junior';

  @override
  String get skillLevel_medium => 'Intermédiaire';

  @override
  String get skillLevel_hard => 'Senior';

  @override
  String get skillLevel_expert => 'Expert';

  @override
  String competencies_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count compétences',
      one: '1 compétence',
      zero: 'Aucune compétence',
    );
    return '$_temp0';
  }

  @override
  String get show_more => 'Afficher plus';

  @override
  String get show_less => 'Voir moins';

  @override
  String discover_job_profile(String jobTitle) {
    return 'Découvrez le profil de compétences pour le métier de $jobTitle !';
  }

  @override
  String job_profile_page_title(String jobTitle) {
    return 'Murya - Profil de compétences : $jobTitle';
  }

  @override
  String get link_copied => 'Lien copié dans le presse-papier';

  @override
  String discover_cf_profile(String cfTitle) {
    return 'Découvrez le profil de compétences pour la famille de compétences $cfTitle !';
  }

  @override
  String get hard_skill => 'Savoir-faire';

  @override
  String get soft_skill => 'Savoir-être';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get expert => 'Expert';

  @override
  String get consult => 'Consulter';

  @override
  String get ranking_per_day => 'Aujourd\'hui';

  @override
  String get ranking_per_week => 'Cette semaine';

  @override
  String get ranking_per_month => 'Ce mois-ci';

  @override
  String get ranking => 'Classement';
}
