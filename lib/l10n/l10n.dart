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
  /// **'Aucun résultat trouvé pour \"{query}\".'**
  String searchNoResults(String query);

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

  /// Niveau de compétence facile
  ///
  /// In fr, this message translates to:
  /// **'Junior'**
  String get skillLevel_easy;

  /// Niveau de compétence moyen
  ///
  /// In fr, this message translates to:
  /// **'Intermédiaire'**
  String get skillLevel_medium;

  /// Niveau de compétence difficile
  ///
  /// In fr, this message translates to:
  /// **'Senior'**
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

  /// Infobulle pour une compétence très bonne
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes en progression !'**
  String get competencyRatingVeryGoodTooltip;

  /// Infobulle pour une compétence bonne
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes en progression !'**
  String get competencyRatingGoodTooltip;

  /// Infobulle pour une compétence moyenne
  ///
  /// In fr, this message translates to:
  /// **'Vous avez besoin de pratiquer davantage.'**
  String get competencyRatingAverageTooltip;

  /// Infobulle pour une compétence mauvaise
  ///
  /// In fr, this message translates to:
  /// **'Vous avez besoin de pratiquer davantage.'**
  String get competencyRatingBadTooltip;

  /// Infobulle pour une compétence très mauvaise
  ///
  /// In fr, this message translates to:
  /// **'Vous avez besoin de pratiquer davantage.'**
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
  /// **'Murya - #{jobTitle}#'**
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

  /// Titre de la popup avant de commencer le quiz
  ///
  /// In fr, this message translates to:
  /// **'Prêt(e) à vous évaluer ?'**
  String get quiz_ready_to_evaluate;

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

  /// Badge de statut quand l'utilisateur n'a pas encore répondu au questionnaire
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get parcoursRanking_status_pending;

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
  /// **'Inviter des amis'**
  String get inviteFriends_title;

  /// Texte descriptif du module d'invitation d'amis
  ///
  /// In fr, this message translates to:
  /// **'Dis à tes amis qu\'apprendre avec Murya, c\'est simple, intelligent et récompensé.'**
  String get inviteFriends_description;

  /// Texte du bonus de parrainage (points/diamants)
  ///
  /// In fr, this message translates to:
  /// **'Invite-les et gagne {amount} 💎 dès leur inscription.'**
  String inviteFriends_bonus(int amount);

  /// Placeholder pour le nom d'utilisateur anonyme
  ///
  /// In fr, this message translates to:
  /// **'Prénom Nom'**
  String get user_anonymous_placeholder;
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
