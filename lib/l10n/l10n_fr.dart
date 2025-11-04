// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'NAVY';

  @override
  String greeting(String name) {
    return 'Bonjour $name!';
  }

  @override
  String get landing_page_title => 'Page d’accueil';

  @override
  String get landing_first_title => 'Augmentez vos compétences';

  @override
  String get landing_first_subtitle =>
      'L’inscription et la connexion à Murya sont gratuites';

  @override
  String get landing_first_button1 => 'Inscription';

  @override
  String get landing_first_button2 => 'Connexion';

  @override
  String get landing_second_title => 'Progressez dans votre métier';

  @override
  String get landing_second_subtitle =>
      'La consultation du catalogue de Murya est libre';

  @override
  String get landing_second_button => 'Rechercher';

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
  String get user_stats_module_title => 'Statistiques de l\'utilisateur';

  @override
  String get user_stats_module_subtitle =>
      'Aperçu des performances et de la progression';

  @override
  String get user_stats_module_button => 'Voir les détails';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat trouvé pour \"$query\".';
  }

  @override
  String get evaluateSkills => 'Évaluer les compétences';

  @override
  String get skillsDiagramTitle => 'Diagramme des compétences';

  @override
  String get skillLevel_easy => 'Facile';

  @override
  String get skillLevel_medium => 'Moyen';

  @override
  String get skillLevel_hard => 'Difficile';

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
}
