import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'NAVY'**
  String get appTitle;

  /// Salue l'utilisateur par son nom
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}!'**
  String greeting(String name);

  /// Titre de la page d'atterrissage
  ///
  /// In fr, this message translates to:
  /// **'Page d’accueil'**
  String get landing_page_title;

  /// Titre de la première boîte sur la page d'atterrissage
  ///
  /// In fr, this message translates to:
  /// **'Augmentez vos compétences'**
  String get landing_first_title;

  /// Sous-titre de la première boîte sur la page d'atterrissage
  ///
  /// In fr, this message translates to:
  /// **'L’inscription et la connexion à Murya sont gratuites'**
  String get landing_first_subtitle;

  /// Texte du premier bouton de la première boîte
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get landing_first_button1;

  /// Texte du second bouton de la première boîte
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get landing_first_button2;

  /// Titre de la deuxième boîte sur la page d'atterrissage
  ///
  /// In fr, this message translates to:
  /// **'Progressez dans votre métier'**
  String get landing_second_title;

  /// Sous-titre de la deuxième boîte sur la page d'atterrissage
  ///
  /// In fr, this message translates to:
  /// **'La consultation du catalogue de Murya est libre'**
  String get landing_second_subtitle;

  /// Texte du bouton de la deuxième boîte
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get landing_second_button;

  /// Libellé du changement de langue vers l'anglais
  ///
  /// In fr, this message translates to:
  /// **'🇬🇧 English'**
  String get footer_language_english;

  /// Libellé du changement de langue vers le français
  ///
  /// In fr, this message translates to:
  /// **'🇫🇷 Français'**
  String get footer_language_french;

  /// Lien vers les mentions légales
  ///
  /// In fr, this message translates to:
  /// **'Mentions légales'**
  String get footer_legal_mentions;

  /// Lien vers les règles de confidentialité
  ///
  /// In fr, this message translates to:
  /// **'Règles de confidentialité'**
  String get footer_privacy_policy;

  /// Lien vers les paramètres des cookies
  ///
  /// In fr, this message translates to:
  /// **'Paramètres des cookies'**
  String get footer_cookie_settings;

  /// Lien vers la page accessibilité
  ///
  /// In fr, this message translates to:
  /// **'Accessibilité'**
  String get footer_accessibility;

  /// Droits d'auteur affichés dans le pied de page
  ///
  /// In fr, this message translates to:
  /// **'2025 Murya SAS'**
  String get footer_copyright;

  /// Texte d'espace réservé pour la barre de recherche
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des compétences et des métiers'**
  String get search_placeholder;

  /// Titre du module des statistiques de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Statistiques de l\'\'utilisateur'**
  String get user_stats_module_title;

  /// Sous-titre du module des statistiques de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Aperçu des performances et de la progression'**
  String get user_stats_module_subtitle;

  /// Texte du bouton dans le module des statistiques de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Voir les détails'**
  String get user_stats_module_button;

  /// Message affiché lorsque la recherche ne retourne aucun résultat
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat trouvé pour \"{query}\".'**
  String searchNoResults(String query);

  /// Bouton pour évaluer les compétences
  ///
  /// In fr, this message translates to:
  /// **'Évaluer les compétences'**
  String get evaluateSkills;

  /// Titre du diagramme des compétences
  ///
  /// In fr, this message translates to:
  /// **'Diagramme des compétences'**
  String get skillsDiagramTitle;

  /// Niveau de compétence facile
  ///
  /// In fr, this message translates to:
  /// **'Facile'**
  String get skillLevel_easy;

  /// Niveau de compétence moyen
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get skillLevel_medium;

  /// Niveau de compétence difficile
  ///
  /// In fr, this message translates to:
  /// **'Difficile'**
  String get skillLevel_hard;

  /// Niveau de compétence expert
  ///
  /// In fr, this message translates to:
  /// **'Expert'**
  String get skillLevel_expert;

  /// Affiche le nombre de compétences avec une gestion plurielle
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {Aucune compétence} =1 {1 compétence} other {{count} compétences}}'**
  String competencies_count(int count);

  /// Texte pour le bouton 'Afficher plus'
  ///
  /// In fr, this message translates to:
  /// **'Afficher plus'**
  String get show_more;

  /// Texte pour le bouton 'Voir moins'
  ///
  /// In fr, this message translates to:
  /// **'Voir moins'**
  String get show_less;

  /// Texte incitant l'utilisateur à découvrir le profil de compétences d'un métier
  ///
  /// In fr, this message translates to:
  /// **'Découvrez le profil de compétences pour le métier de {jobTitle} !'**
  String discover_job_profile(String jobTitle);

  /// Titre de la page du profil de compétences d'un métier
  ///
  /// In fr, this message translates to:
  /// **'Murya - Profil de compétences : {jobTitle}'**
  String job_profile_page_title(String jobTitle);

  /// Message affiché lorsque le lien est copié dans le presse-papier
  ///
  /// In fr, this message translates to:
  /// **'Lien copié dans le presse-papier'**
  String get link_copied;

  /// Texte incitant l'utilisateur à découvrir le profil de compétences d'une famille de compétences
  ///
  /// In fr, this message translates to:
  /// **'Découvrez le profil de compétences pour la famille de compétences {cfTitle} !'**
  String discover_cf_profile(String cfTitle);

  /// No description provided for @hard_skill.
  ///
  /// In fr, this message translates to:
  /// **'Savoir-faire'**
  String get hard_skill;

  /// No description provided for @soft_skill.
  ///
  /// In fr, this message translates to:
  /// **'Savoir-être'**
  String get soft_skill;

  /// No description provided for @easy.
  ///
  /// In fr, this message translates to:
  /// **'Facile'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In fr, this message translates to:
  /// **'Difficile'**
  String get hard;

  /// No description provided for @expert.
  ///
  /// In fr, this message translates to:
  /// **'Expert'**
  String get expert;

  /// Texte pour le bouton 'Consulter'
  ///
  /// In fr, this message translates to:
  /// **'Consulter'**
  String get consult;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
