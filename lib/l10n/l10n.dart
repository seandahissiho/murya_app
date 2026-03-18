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
  /// **'MURYA'**
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
  /// **'Parcours'**
  String get landing_first_title;

  /// Sous-titre de la première boîte sur la page d'atterrissage
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte, explorez et progressez. C\'\'est gratuit et sans frais cachés.'**
  String get landing_first_subtitle;

  /// Texte du premier bouton de la première boîte
  ///
  /// In fr, this message translates to:
  /// **'Piloter'**
  String get landing_first_button1;

  /// Texte du second bouton de la première boîte
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get landing_first_button2;

  /// Titre de la deuxième boîte sur la page d'atterrissage
  ///
  /// In fr, this message translates to:
  /// **'Compétences'**
  String get landing_second_title;

  /// Sous-titre de la deuxième boîte sur la page d'atterrissage
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre métier et lancez-vous. Des questions courtes, des progrès concrets.'**
  String get landing_second_subtitle;

  /// Texte du bouton de la deuxième boîte
  ///
  /// In fr, this message translates to:
  /// **'Perfectionner'**
  String get landing_second_button;

  /// Titre de la page d'accueil dans l'onglet du navigateur
  ///
  /// In fr, this message translates to:
  /// **'Murya - Page d\'\'accueil'**
  String get landing_browser_title;

  /// Titre du dialogue de personnalisation de la landing
  ///
  /// In fr, this message translates to:
  /// **'Personnaliser la landing'**
  String get landing_customize_title;

  /// Description dans le dialogue de personnalisation de la landing
  ///
  /// In fr, this message translates to:
  /// **'Organisez vos modules, ajoutez-en de nouveaux, ou retirez ceux qui ne sont pas obligatoires.'**
  String get landing_customize_description;

  /// Message d'état vide pour une liste de modules
  ///
  /// In fr, this message translates to:
  /// **'Aucun module disponible.'**
  String get modules_empty_state;

  /// Bouton pour ajouter un module sur la landing
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un module'**
  String get landing_add_module;

  /// Bouton pour consulter l'audit de la landing
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'\'audit'**
  String get landing_view_audit;

  /// Libellé indiquant un module par défaut
  ///
  /// In fr, this message translates to:
  /// **'Default'**
  String get label_default;

  /// Libellé générique pour l'action de suppression
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get action_remove;

  /// Titre du catalogue des modules
  ///
  /// In fr, this message translates to:
  /// **'Catalogue des modules'**
  String get modules_catalog_title;

  /// Libellé indiquant qu'un élément est déjà ajouté
  ///
  /// In fr, this message translates to:
  /// **'Ajoute'**
  String get status_added;

  /// Titre de la section audit de la landing
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get landing_audit_title;

  /// Message affiché quand il n'y a pas d'événements d'audit
  ///
  /// In fr, this message translates to:
  /// **'Aucune action enregistree.'**
  String get landing_audit_empty;

  /// Libellé de l'acteur système dans l'audit
  ///
  /// In fr, this message translates to:
  /// **'SYSTEM'**
  String get landing_audit_actor_system;

  /// Libellé de l'acteur utilisateur dans l'audit
  ///
  /// In fr, this message translates to:
  /// **'USER'**
  String get landing_audit_actor_user;

  /// Libellé d'action pour un module retiré dans l'audit
  ///
  /// In fr, this message translates to:
  /// **'a retire'**
  String get landing_audit_action_removed;

  /// Libellé d'action pour un module ajouté dans l'audit
  ///
  /// In fr, this message translates to:
  /// **'a ajoute'**
  String get landing_audit_action_added;

  /// Titre de la section interactions de la landing
  ///
  /// In fr, this message translates to:
  /// **'Interactions'**
  String get landing_interactions_title;

  /// Libellé générique pour l'action d'ajout
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get action_add;

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
  /// **'Rechercher'**
  String get search_placeholder;

  /// Titre du module des ressources de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Ressources'**
  String get user_ressources_module_title;

  /// Sous-titre du module des ressources de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'La génération des contenus de Murya est instantanée'**
  String get user_ressources_module_subtitle;

  /// Texte du bouton dans le module des ressources de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Personnaliser'**
  String get user_ressources_module_button;

  /// Message affiché lorsque la recherche ne retourne aucun résultat
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour {query}'**
  String searchNoResults(String query);

  /// Sous-texte affiché sous le message de recherche sans résultat
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez l\'\'orthographe de tous les mots.\nEssayez différents mots-clés.\nEssayez des mots-clés plus généraux.'**
  String get searchNoResultsSubtitle;

  /// No description provided for @landingSkillButtonText.
  ///
  /// In fr, this message translates to:
  /// **'Perfectionner'**
  String get landingSkillButtonText;

  /// Bouton pour évaluer les compétences
  ///
  /// In fr, this message translates to:
  /// **'Évaluer les compétences'**
  String get evaluateSkills;

  /// Indique le temps restant avant la prochaine évaluation des compétences
  ///
  /// In fr, this message translates to:
  /// **'Prochaine évaluation - {time}'**
  String evaluateSkillsAvailableIn(String time);

  /// Titre du diagramme des compétences
  ///
  /// In fr, this message translates to:
  /// **'Diagramme'**
  String get skillsDiagramTitle;

  /// Titre de la section compte dans le profil
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get profile_account_title;

  /// Niveau de progression débutant
  ///
  /// In fr, this message translates to:
  /// **'Débutant'**
  String get skillLevel_easy;

  /// Niveau de progression junior
  ///
  /// In fr, this message translates to:
  /// **'Junior'**
  String get skillLevel_medium;

  /// Niveau de progression intermédiaire
  ///
  /// In fr, this message translates to:
  /// **'Intermédiaire'**
  String get skillLevel_hard;

  /// Niveau de progression senior
  ///
  /// In fr, this message translates to:
  /// **'Senior'**
  String get skillLevel_expert;

  /// Affiche le nombre de compétences avec une gestion plurielle
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {Aucune compétence} =1 {1 compétence} other {{count} compétences}}'**
  String competencies_count(int count);

  /// Infobulle pour une compétence très bonne
  ///
  /// In fr, this message translates to:
  /// **'Cet indicateur reflète votre évolution'**
  String get competencyRatingVeryGoodTooltip;

  /// Infobulle pour une compétence bonne
  ///
  /// In fr, this message translates to:
  /// **'Cet indicateur reflète votre évolution'**
  String get competencyRatingGoodTooltip;

  /// Infobulle pour une compétence moyenne
  ///
  /// In fr, this message translates to:
  /// **'Cet indicateur reflète votre évolution'**
  String get competencyRatingAverageTooltip;

  /// Infobulle pour une compétence mauvaise
  ///
  /// In fr, this message translates to:
  /// **'Cet indicateur reflète votre évolution'**
  String get competencyRatingBadTooltip;

  /// Infobulle pour une compétence très mauvaise
  ///
  /// In fr, this message translates to:
  /// **'Cet indicateur reflète votre évolution'**
  String get competencyRatingVeryBadTooltip;

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
  /// **'Murya - {jobTitle}'**
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

  /// No description provided for @ranking_per_day.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'\'hui'**
  String get ranking_per_day;

  /// No description provided for @ranking_per_week.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get ranking_per_week;

  /// No description provided for @ranking_per_month.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois-ci'**
  String get ranking_per_month;

  /// Titre pour la section de classement
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get ranking;

  /// Titre du popup de sélection de métier
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre métier'**
  String get popup_job_selection_title;

  /// Titre du métier de technicien en cybersécurité dans le popup
  ///
  /// In fr, this message translates to:
  /// **'Technicien en Cybersécurité'**
  String get popup_job_selection_technician_title;

  /// Sous-titre du métier de technicien en cybersécurité dans le popup
  ///
  /// In fr, this message translates to:
  /// **'Protégez les infrastructures critiques. Devenez un expert recherché.'**
  String get popup_job_selection_technician_subtitle;

  /// Texte du bouton continuer dans le popup de sélection de métier
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get popup_job_selection_continue_button;

  /// Label pour la section d'autre expertise dans le popup
  ///
  /// In fr, this message translates to:
  /// **'Vous visez une autre expertise?'**
  String get popup_job_selection_other_expertise_label;

  /// Hint text pour la recherche d'autre expertise dans le popup
  ///
  /// In fr, this message translates to:
  /// **'Ex: Développeur, Product Manager...'**
  String get popup_job_selection_search_hint;

  /// Titre de la page de visualisation des ressources
  ///
  /// In fr, this message translates to:
  /// **'Page Visualiseur de Ressource'**
  String get resourceViewerPageTitle;

  /// Message d'erreur pour les types de ressources non supportés
  ///
  /// In fr, this message translates to:
  /// **'Type de ressource non supporté'**
  String get unsupportedResourceType;

  /// Message d'erreur quand une ressource vidéo n'a pas d'URL
  ///
  /// In fr, this message translates to:
  /// **'L\'\'URL de la vidéo est manquante'**
  String get videoViewerMissingUrl;

  /// Message d'erreur quand l'URL vidéo n'est pas en https
  ///
  /// In fr, this message translates to:
  /// **'L\'\'URL de la vidéo doit utiliser http ou https'**
  String get videoViewerInvalidUrl;

  /// Message d'erreur quand une vidéo ne peut pas être chargée
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la vidéo'**
  String get videoViewerLoadFailed;

  /// Message d'erreur quand une ressource audio n'a pas d'URL
  ///
  /// In fr, this message translates to:
  /// **'L\'\'URL audio est manquante'**
  String get audioViewerMissingUrl;

  /// Message d'erreur quand l'URL audio n'est pas en https
  ///
  /// In fr, this message translates to:
  /// **'L\'\'URL audio doit utiliser http ou https'**
  String get audioViewerInvalidUrl;

  /// Message d'erreur quand une ressource audio ne peut pas être chargée
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger l\'\'audio'**
  String get audioViewerLoadFailed;

  /// Titre de l'écran d'accueil
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get homeScreenTitle;

  /// Titre de l'écran de recherche principale
  ///
  /// In fr, this message translates to:
  /// **'Recherche Principale'**
  String get mainSearchTitle;

  /// Libellé court de la page de recherche pour le fil d'ariane
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get searchPageLabel;

  /// Libellé pour la médiathèque
  ///
  /// In fr, this message translates to:
  /// **'Médiathèque'**
  String get mediaLibrary;

  /// Libellé pour le sommaire
  ///
  /// In fr, this message translates to:
  /// **'Sommaire'**
  String get summary;

  /// Libellé pour la section Article
  ///
  /// In fr, this message translates to:
  /// **'Article'**
  String get article;

  /// Durée en heures
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {0 heure} =1 {1 heure} other {{count} heures}}'**
  String duration_hours(int count);

  /// Durée en minutes
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {0 minute} =1 {1 minute} other {{count} minutes}}'**
  String duration_minutes(int count);

  /// Durée en secondes
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {0 seconde} =1 {1 seconde} other {{count} secondes}}'**
  String duration_seconds(int count);

  /// Libellé pour le temps d'action estimé
  ///
  /// In fr, this message translates to:
  /// **'{minutes, plural, =0 {0 minute} =1 {1 minute} other {{minutes} minutes}}'**
  String estimated_action_time(int minutes);

  /// Titre de la popup avant de commencer le quiz
  ///
  /// In fr, this message translates to:
  /// **'Prêt(e) à vous évaluer ?'**
  String get quiz_ready_to_evaluate;

  /// Titre de la popup de démarrage du quiz (challenge)
  ///
  /// In fr, this message translates to:
  /// **'Prêt à relever le défi ?'**
  String get quiz_start_title_challenge;

  /// Préfixe avant la partie mise en valeur du texte de démarrage du quiz
  ///
  /// In fr, this message translates to:
  /// **'Répondez à '**
  String get quiz_start_prompt_prefix;

  /// Texte mis en valeur indiquant le nombre de questions rapides
  ///
  /// In fr, this message translates to:
  /// **'10 questions rapides'**
  String get quiz_start_prompt_emphasis;

  /// Suffixe après la partie mise en valeur du texte de démarrage du quiz
  ///
  /// In fr, this message translates to:
  /// **' pour générer votre ressource sur-mesure.'**
  String get quiz_start_prompt_suffix;

  /// Durée estimée du quiz au démarrage
  ///
  /// In fr, this message translates to:
  /// **'Durée : Moins de 5 min'**
  String get quiz_start_duration;

  /// Titre du bloc conseil au démarrage du quiz
  ///
  /// In fr, this message translates to:
  /// **'💡 Conseil'**
  String get quiz_start_tip_title;

  /// Texte du conseil au démarrage du quiz
  ///
  /// In fr, this message translates to:
  /// **'Répondez à l’instinct pour un résultat plus juste !'**
  String get quiz_start_tip_text;

  /// Titre du popup de sortie du quiz
  ///
  /// In fr, this message translates to:
  /// **'Abandonner l\'\'évaluation ?'**
  String get quiz_exit_title;

  /// Description du popup de sortie du quiz
  ///
  /// In fr, this message translates to:
  /// **'Votre progression sera perdue et vous devrez recommencer depuis le début.'**
  String get quiz_exit_body;

  /// Bouton pour quitter le quiz
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get quiz_exit_quit;

  /// Bouton pour reprendre le quiz
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get quiz_exit_resume;

  /// Libellé pour les réponses correctes dans le résumé du quiz
  ///
  /// In fr, this message translates to:
  /// **'Correct'**
  String get quiz_result_correct;

  /// Libellé pour les réponses incorrectes dans le résumé du quiz
  ///
  /// In fr, this message translates to:
  /// **'Incorrect'**
  String get quiz_result_incorrect;

  /// Libellé du temps du quiz en minutes
  ///
  /// In fr, this message translates to:
  /// **'Temps : {minutes} min'**
  String quiz_time_minutes(int minutes);

  /// Bouton pour continuer après la fin du quiz
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get quiz_continue;

  /// Première ligne de description du début du quiz
  ///
  /// In fr, this message translates to:
  /// **'Vous allez démarrer le questionnaire du métier de Product Manager.'**
  String get quiz_start_description_1;

  /// Deuxième ligne de description du début du quiz
  ///
  /// In fr, this message translates to:
  /// **'Il se compose de 10 questions à choix multiple.'**
  String get quiz_start_description_2;

  /// Troisième ligne de description du début du quiz
  ///
  /// In fr, this message translates to:
  /// **'Vos réponses permettront de créer votre ressource personnalisée.'**
  String get quiz_start_description_3;

  /// Conseil avant de commencer le quiz
  ///
  /// In fr, this message translates to:
  /// **'Conseil : Répondez instinctivement pour une analyse plus juste. Cela prend moins de 5 minutes !'**
  String get quiz_start_advice;

  /// Bouton pour commencer le quiz
  ///
  /// In fr, this message translates to:
  /// **'C\'\'est parti !'**
  String get quiz_lets_go;

  /// Compteur de la question actuelle
  ///
  /// In fr, this message translates to:
  /// **'Question {current}/{total}'**
  String quiz_question_counter(int current, int total);

  /// Bouton pour vérifier la réponse
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get quiz_verify;

  /// Titre lorsque le quiz est terminé
  ///
  /// In fr, this message translates to:
  /// **'Évaluation terminée !'**
  String get quiz_completed_title;

  /// Sous-titre lorsque le quiz est terminé
  ///
  /// In fr, this message translates to:
  /// **'Bravo, vos 10 réponses ont été analysées !'**
  String get quiz_completed_subtitle;

  /// Description lorsque le quiz est terminé
  ///
  /// In fr, this message translates to:
  /// **'Le diagramme de compétences est actualisé et vous pouvez créer la ressource parfaite pour continuer à progresser.'**
  String get quiz_completed_description;

  /// Bouton pour accéder à l'espace utilisateur après le quiz
  ///
  /// In fr, this message translates to:
  /// **'Voir mon espace'**
  String get quiz_see_my_space;

  /// Titre par défaut pour une ressource exemple
  ///
  /// In fr, this message translates to:
  /// **'Ressource Exemple'**
  String get sampleResource;

  /// Libellé singulier pour article
  ///
  /// In fr, this message translates to:
  /// **'un article'**
  String get resourceLabelSingular_article;

  /// Libellé singulier pour vidéo
  ///
  /// In fr, this message translates to:
  /// **'une vidéo'**
  String get resourceLabelSingular_video;

  /// Libellé singulier pour podcast
  ///
  /// In fr, this message translates to:
  /// **'un podcast'**
  String get resourceLabelSingular_podcast;

  /// Libellé singulier pour ressource générique
  ///
  /// In fr, this message translates to:
  /// **'une ressource'**
  String get resourceLabelSingular_default;

  /// Texte du bouton valider
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get popup_validate;

  /// Titre du popup de déblocage
  ///
  /// In fr, this message translates to:
  /// **'Débloquer votre ressource ?'**
  String get popup_unlock_resource_title;

  /// Description du popup de déblocage
  ///
  /// In fr, this message translates to:
  /// **'Utilisez vos points pour générer votre article personnalisé. L\'IA de Murya l\'adaptera instantanément à vos réponses du jour.'**
  String get popup_unlock_resource_description;

  /// Libellé du coût de création
  ///
  /// In fr, this message translates to:
  /// **'Coût de la création'**
  String get cost_creation_label;

  /// Libellé du solde actuel
  ///
  /// In fr, this message translates to:
  /// **'Votre solde actuel'**
  String get cost_current_balance_label;

  /// Libellé du solde restant
  ///
  /// In fr, this message translates to:
  /// **'Votre solde restant (après création)'**
  String get cost_remaining_balance_label;

  /// Texte de chargement pendant la création
  ///
  /// In fr, this message translates to:
  /// **'Création de votre ressource...'**
  String get loading_creating_resource;

  /// Titre de chargement pendant la création
  ///
  /// In fr, this message translates to:
  /// **'Murya est au travail !'**
  String get loading_murya_working;

  /// Description de chargement pendant la création
  ///
  /// In fr, this message translates to:
  /// **'Nous analysons vos 10 réponses pour rédiger un article unique, parfaitement adapté aux compétences que vous devez renforcer.'**
  String get loading_analyzing_answers;

  /// Texte du bouton pour créer une ressource
  ///
  /// In fr, this message translates to:
  /// **'Créer {resourceLabel}'**
  String create_resource_button(String resourceLabel);

  /// Titre pour la page des ressources
  ///
  /// In fr, this message translates to:
  /// **'Page Ressources'**
  String get resourcesPageTitle;

  /// En-tête pour l'écran des ressources
  ///
  /// In fr, this message translates to:
  /// **'Ressources'**
  String get page_title_resources;

  /// En-tête de section pour les articles
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get section_articles;

  /// En-tête de section pour les vidéos
  ///
  /// In fr, this message translates to:
  /// **'Vidéos'**
  String get section_videos;

  /// En-tête de section pour les podcasts
  ///
  /// In fr, this message translates to:
  /// **'Podcasts'**
  String get section_podcasts;

  /// No description provided for @quiz_daily_performance.
  ///
  /// In fr, this message translates to:
  /// **'Votre performance du jour'**
  String get quiz_daily_performance;

  /// No description provided for @quiz_good_answers.
  ///
  /// In fr, this message translates to:
  /// **'Bonnes réponses'**
  String get quiz_good_answers;

  /// No description provided for @quiz_answers_to_review.
  ///
  /// In fr, this message translates to:
  /// **'Réponses à revoir'**
  String get quiz_answers_to_review;

  /// No description provided for @quiz_reward.
  ///
  /// In fr, this message translates to:
  /// **'Récompense'**
  String get quiz_reward;

  /// Titre principal de la page Parcours
  ///
  /// In fr, this message translates to:
  /// **'Parcours'**
  String get parcoursPageTitle;

  /// Onglet Profil dans la page Parcours
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get parcoursTab_profile;

  /// Onglet Objectifs dans la page Parcours
  ///
  /// In fr, this message translates to:
  /// **'Objectifs'**
  String get parcoursTab_objectives;

  /// Onglet Récompenses dans la page Parcours
  ///
  /// In fr, this message translates to:
  /// **'Récompenses'**
  String get parcoursTab_rewards;

  /// Onglet Paramètres dans la page Parcours
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get parcoursTab_settings;

  /// Label du nombre de personnes dans le classement Parcours
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {0 personne} =1 {1 personne} other {{count} personnes}}'**
  String parcoursRanking_peopleCount(int count);

  /// En-tête de colonne Personne dans le tableau de classement Parcours
  ///
  /// In fr, this message translates to:
  /// **'Personne'**
  String get parcoursRanking_header_person;

  /// En-tête de colonne Expérience dans le tableau de classement Parcours
  ///
  /// In fr, this message translates to:
  /// **'Expérience'**
  String get parcoursRanking_header_experience;

  /// En-tête de colonne Questions répondues dans le tableau de classement Parcours
  ///
  /// In fr, this message translates to:
  /// **'Question répondu'**
  String get parcoursRanking_header_answeredQuestions;

  /// En-tête de colonne Performance dans le tableau de classement Parcours
  ///
  /// In fr, this message translates to:
  /// **'Performance'**
  String get parcoursRanking_header_performance;

  /// Texte affichant le nombre de questions répondues et la date de début
  ///
  /// In fr, this message translates to:
  /// **'{count} depuis {date}'**
  String parcoursRanking_answeredSince(int count, String date);

  /// Badge de statut quand l'utilisateur n'a pas encore répondu au questionnaire
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get parcoursRanking_status_pending;

  /// Indicateur affiché à côté de l'utilisateur courant dans le classement
  ///
  /// In fr, this message translates to:
  /// **'(Vous)'**
  String get parcoursRanking_youTag;

  /// Titre du bloc objectif en cours (colonne droite)
  ///
  /// In fr, this message translates to:
  /// **'Objectif en cours'**
  String get parcoursObjective_inProgress;

  /// Texte de l'objectif affiché sur la page Parcours
  ///
  /// In fr, this message translates to:
  /// **'Finaliser le parcours de positionnement'**
  String get parcoursObjective_finalizePositioningPath;

  /// Titre du bloc Récompenses possibles (colonne droite)
  ///
  /// In fr, this message translates to:
  /// **'Récompenses possibles'**
  String get parcoursRewards_possibleTitle;

  /// Lien/Bouton pour afficher toutes les récompenses
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get parcoursRewards_seeAll;

  /// Nombre de places restantes pour une récompense
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {0 place restante} =1 {1 place restante} other {{count} places restantes}}'**
  String reward_remainingPlaces(int count);

  /// Bouton pour débloquer une récompense
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get reward_unlock_cta;

  /// Infobulle affichée quand une récompense est inactive faute de diamants
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'\'avez pas assez de 💎'**
  String get reward_unlock_insufficientDiamonds_tooltip;

  /// Libellé du type de récompense cinéma
  ///
  /// In fr, this message translates to:
  /// **'Cinéma'**
  String get rewardKind_cinema;

  /// Libellé du type de récompense salle de concert
  ///
  /// In fr, this message translates to:
  /// **'Salle de concert'**
  String get rewardKind_concertHall;

  /// Libellé du type de récompense théâtre
  ///
  /// In fr, this message translates to:
  /// **'Salle de spectacle'**
  String get rewardKind_theatre;

  /// Libellé du type de récompense match de sport
  ///
  /// In fr, this message translates to:
  /// **'Match de basket'**
  String get rewardKind_sportsMatch;

  /// Libellé du type de récompense parc d'attractions
  ///
  /// In fr, this message translates to:
  /// **'Parc d\'\'attractions'**
  String get rewardKind_themePark;

  /// Libellé du type de récompense autre
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get rewardKind_other;

  /// Nom d'une récompense possible
  ///
  /// In fr, this message translates to:
  /// **'Les francofolies de La Rochelle'**
  String get rewardItem_francofoliesLaRochelle;

  /// Nom d'une récompense possible
  ///
  /// In fr, this message translates to:
  /// **'Futuroscope'**
  String get rewardItem_futuroscope;

  /// Nom d'une récompense possible
  ///
  /// In fr, this message translates to:
  /// **'Place de cinéma'**
  String get rewardItem_cinemaTicket;

  /// Titre du bloc Activités récentes
  ///
  /// In fr, this message translates to:
  /// **'Activités récentes'**
  String get parcoursRecentActivities_title;

  /// Titre du module d'invitation d'amis
  ///
  /// In fr, this message translates to:
  /// **'Challenge tes amis !'**
  String get inviteFriends_title;

  /// Texte du bonus de parrainage (points/diamants)
  ///
  /// In fr, this message translates to:
  /// **'Chaque ami qui te rejoint, c\'\'est {amount} 💎 offerts.'**
  String inviteFriends_bonus(int amount);

  /// Texte du bouton d'appel à l'action pour inviter des amis
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get inviteFriends_cta;

  /// Libellé générique pour un bouton OK
  ///
  /// In fr, this message translates to:
  /// **'Ok'**
  String get common_ok;

  /// Titre de la modale indiquant qu'une fonctionnalité n'est pas disponible
  ///
  /// In fr, this message translates to:
  /// **'Version de démonstration'**
  String get popup_contentNotAvailable_title;

  /// Texte de la modale indiquant qu'une fonctionnalité n'est pas disponible
  ///
  /// In fr, this message translates to:
  /// **'Cette fonctionnalité n\'\'est pas accessible dans le prototype. Elle sera débloquée dans la version complète de Murya.'**
  String get popup_contentNotAvailable_body;

  /// Bouton de fermeture de la modale indiquant qu'une fonctionnalité n'est pas disponible
  ///
  /// In fr, this message translates to:
  /// **'Ok, c\'\'est compris'**
  String get popup_contentNotAvailable_cta;

  /// Titre principal de l'écran de chargement d'authentification
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get authLoading_title;

  /// Message de progression pour l'initialisation
  ///
  /// In fr, this message translates to:
  /// **'Initialisation du moteur...'**
  String get authLoading_message_engineInit;

  /// Message de progression pour le chargement des artefacts UI
  ///
  /// In fr, this message translates to:
  /// **'Chargement des artefacts UI...'**
  String get authLoading_message_uiArtifacts;

  /// Message de progression pour la vérification des autorisations
  ///
  /// In fr, this message translates to:
  /// **'Vérification des autorisations...'**
  String get authLoading_message_permissionsCheck;

  /// Message de progression pour la compilation des modules
  ///
  /// In fr, this message translates to:
  /// **'Compilation des modules...'**
  String get authLoading_message_modulesCompile;

  /// Message de progression pour la synchronisation du cache
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation du cache local...'**
  String get authLoading_message_cacheSync;

  /// Message de progression pour la récupération du profil utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Récupération du profil utilisateur...'**
  String get authLoading_message_profileFetch;

  /// Message de progression pour la préparation de session
  ///
  /// In fr, this message translates to:
  /// **'Préparation de la session...'**
  String get authLoading_message_sessionPrep;

  /// Message de progression pour l'optimisation du rendu
  ///
  /// In fr, this message translates to:
  /// **'Optimisation du rendu...'**
  String get authLoading_message_renderOptimize;

  /// Message de progression pour la finalisation
  ///
  /// In fr, this message translates to:
  /// **'Finalisation...'**
  String get authLoading_message_finalize;

  /// Ligne de statut de chargement avec pourcentage
  ///
  /// In fr, this message translates to:
  /// **'Chargement des ressources • {percent}%'**
  String authLoading_debugLine(int percent);

  /// Libellé du chip pour un nouvel élément
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get chip_new;

  /// Libellé du chip pour un élément en attente
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get chip_pending;

  /// Placeholder pour le prénom de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get user_firstName_placeholder;

  /// Placeholder pour le nom de famille de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get user_lastName_placeholder;

  /// Placeholder pour le nom d'utilisateur anonyme
  ///
  /// In fr, this message translates to:
  /// **'Prénom Nom'**
  String get user_anonymous_placeholder;

  /// Message de série de jours consécutifs
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {Premier jour !} =1 {Premier jour !} other {{count} jours consécutifs}}'**
  String streakDays(int count);

  /// Libellé pour le champ e-mail
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get email_label;

  /// Message d'erreur pour un e-mail invalide
  ///
  /// In fr, this message translates to:
  /// **'E-mail invalide'**
  String get email_invalid_error;

  /// Libellé du diplôme
  ///
  /// In fr, this message translates to:
  /// **'Diplôme'**
  String get diploma_label;

  /// Libellé de l'année de promotion
  ///
  /// In fr, this message translates to:
  /// **'Promotion'**
  String get diplomaYear_label;

  /// Libellé de l'établissement
  ///
  /// In fr, this message translates to:
  /// **'Établissement'**
  String get diplomaSchool_label;

  /// Libellé du bouton d'enregistrement
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get saveChanges_button;

  /// Libellé du bouton de modification
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get editChanges_button;

  /// Filtre de recherche : tous
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get search_filter_all;

  /// Filtre de recherche : métiers
  ///
  /// In fr, this message translates to:
  /// **'Métiers'**
  String get search_filter_job;

  /// Filtre de recherche : ressources
  ///
  /// In fr, this message translates to:
  /// **'Ressources'**
  String get search_filter_resource;

  /// Filtre de recherche : profils
  ///
  /// In fr, this message translates to:
  /// **'Profils'**
  String get search_filter_profile;
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
