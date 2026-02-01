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
  String get landing_first_title => 'Parcours';

  @override
  String get landing_first_subtitle =>
      'Créez votre compte, explorez et progressez. C\'est gratuit et sans frais cachés.';

  @override
  String get landing_first_button1 => 'Piloter';

  @override
  String get landing_first_button2 => 'Connexion';

  @override
  String get landing_second_title => 'Compétences';

  @override
  String get landing_second_subtitle =>
      'Choisissez votre métier et lancez-vous. Des questions courtes, des progrès concrets.';

  @override
  String get landing_second_button => 'Perfectionner';

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
  String get user_ressources_module_title => 'Ressources';

  @override
  String get user_ressources_module_subtitle =>
      'La génération des contenus de Murya est instantanée';

  @override
  String get user_ressources_module_button => 'Personnaliser';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat trouvé pour \"$query\".';
  }

  @override
  String get landingSkillButtonText => 'Perfectionner';

  @override
  String get evaluateSkills => 'Évaluer les compétences';

  @override
  String evaluateSkillsAvailableIn(String time) {
    return 'Prochaine évaluation - $time';
  }

  @override
  String get skillsDiagramTitle => 'Diagramme';

  @override
  String get profile_account_title => 'Compte';

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
  String get competencyRatingVeryGoodTooltip =>
      'Cet indicateur reflète votre évolution.';

  @override
  String get competencyRatingGoodTooltip =>
      'Cet indicateur reflète votre évolution.';

  @override
  String get competencyRatingAverageTooltip =>
      'Cet indicateur reflète votre évolution.';

  @override
  String get competencyRatingBadTooltip =>
      'Cet indicateur reflète votre évolution.';

  @override
  String get competencyRatingVeryBadTooltip =>
      'Cet indicateur reflète votre évolution.';

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
    return 'Murya - $jobTitle';
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

  @override
  String get popup_job_selection_title => 'Choisissez votre métier';

  @override
  String get popup_job_selection_technician_title =>
      'Technicien en Cybersécurité';

  @override
  String get popup_job_selection_technician_subtitle =>
      'Protégez les infrastructures critiques. Devenez un expert recherché.';

  @override
  String get popup_job_selection_continue_button => 'Continuer';

  @override
  String get popup_job_selection_other_expertise_label =>
      'Vous visez une autre expertise?';

  @override
  String get popup_job_selection_search_hint =>
      'Ex: Développeur, Product Manager...';

  @override
  String get resourceViewerPageTitle => 'Page Visualiseur de Ressource';

  @override
  String get unsupportedResourceType => 'Type de ressource non supporté';

  @override
  String get videoViewerMissingUrl => 'L\'URL de la vidéo est manquante';

  @override
  String get videoViewerInvalidUrl =>
      'L\'URL de la vidéo doit utiliser http ou https';

  @override
  String get videoViewerLoadFailed => 'Impossible de charger la vidéo';

  @override
  String get audioViewerMissingUrl => 'L\'URL audio est manquante';

  @override
  String get audioViewerInvalidUrl =>
      'L\'URL audio doit utiliser http ou https';

  @override
  String get audioViewerLoadFailed => 'Impossible de charger l\'audio';

  @override
  String get homeScreenTitle => 'Accueil';

  @override
  String get mainSearchTitle => 'Recherche Principale';

  @override
  String get mediaLibrary => 'Médiathèque';

  @override
  String get summary => 'Sommaire';

  @override
  String get article => 'Article';

  @override
  String get quiz_ready_to_evaluate => 'Prêt(e) à vous évaluer ?';

  @override
  String get quiz_start_description_1 =>
      'Vous allez démarrer le questionnaire du métier de Product Manager.';

  @override
  String get quiz_start_description_2 =>
      'Il se compose de 10 questions à choix multiple.';

  @override
  String get quiz_start_description_3 =>
      'Vos réponses permettront de créer votre ressource personnalisée.';

  @override
  String get quiz_start_advice =>
      'Conseil : Répondez instinctivement pour une analyse plus juste. Cela prend moins de 5 minutes !';

  @override
  String get quiz_lets_go => 'C\'est parti !';

  @override
  String quiz_question_counter(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get quiz_verify => 'Vérifier';

  @override
  String get quiz_completed_title => 'Évaluation terminée !';

  @override
  String get quiz_completed_subtitle =>
      'Bravo, vos 10 réponses ont été analysées !';

  @override
  String get quiz_completed_description =>
      'Le diagramme de compétences est actualisé et vous pouvez créer la ressource parfaite pour continuer à progresser.';

  @override
  String get quiz_see_my_space => 'Voir mon espace';

  @override
  String get sampleResource => 'Ressource Exemple';

  @override
  String get resourceLabelSingular_article => 'un article';

  @override
  String get resourceLabelSingular_video => 'une vidéo';

  @override
  String get resourceLabelSingular_podcast => 'un podcast';

  @override
  String get resourceLabelSingular_default => 'une ressource';

  @override
  String get popup_validate => 'Valider';

  @override
  String get popup_unlock_resource_title => 'Débloquer votre ressource ?';

  @override
  String get popup_unlock_resource_description =>
      'Utilisez vos points pour générer votre article personnalisé. LIA de Murya ladaptera instantanément à vos réponses du jour.';

  @override
  String get cost_creation_label => 'Coût de la création';

  @override
  String get cost_current_balance_label => 'Votre solde actuel';

  @override
  String get cost_remaining_balance_label =>
      'Votre solde restant (après création)';

  @override
  String get loading_creating_resource => 'Création de votre ressource...';

  @override
  String get loading_murya_working => 'Murya est au travail !';

  @override
  String get loading_analyzing_answers =>
      'Nous analysons vos 10 réponses pour rédiger un article unique, parfaitement adapté aux compétences que vous devez renforcer.';

  @override
  String create_resource_button(String resourceLabel) {
    return 'Créer $resourceLabel';
  }

  @override
  String get resourcesPageTitle => 'Page Ressources';

  @override
  String get page_title_resources => 'Ressources';

  @override
  String get section_articles => 'Articles';

  @override
  String get section_videos => 'Vidéos';

  @override
  String get section_podcasts => 'Podcasts';

  @override
  String get quiz_daily_performance => 'Votre performance du jour';

  @override
  String get quiz_good_answers => 'Bonnes réponses';

  @override
  String get quiz_answers_to_review => 'Réponses à revoir';

  @override
  String get quiz_reward => 'Récompense';

  @override
  String get parcoursPageTitle => 'Parcours';

  @override
  String get parcoursTab_profile => 'Profil';

  @override
  String get parcoursTab_objectives => 'Objectifs';

  @override
  String get parcoursTab_rewards => 'Récompenses';

  @override
  String get parcoursTab_settings => 'Paramètres';

  @override
  String parcoursRanking_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
      zero: '0 personne',
    );
    return '$_temp0';
  }

  @override
  String get parcoursRanking_header_person => 'Personne';

  @override
  String get parcoursRanking_header_experience => 'Expérience';

  @override
  String get parcoursRanking_header_answeredQuestions => 'Question répondu';

  @override
  String get parcoursRanking_header_performance => 'Performance';

  @override
  String parcoursRanking_answeredSince(int count, String date) {
    return '$count depuis $date';
  }

  @override
  String get parcoursRanking_status_pending => 'En attente';

  @override
  String get parcoursRanking_youTag => '(Vous)';

  @override
  String get parcoursObjective_inProgress => 'Objectif en cours';

  @override
  String get parcoursObjective_finalizePositioningPath =>
      'Finaliser le parcours de positionnement';

  @override
  String get parcoursRewards_possibleTitle => 'Récompenses possibles';

  @override
  String get parcoursRewards_seeAll => 'Voir tout';

  @override
  String reward_remainingPlaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places restantes',
      one: '1 place restante',
      zero: '0 place restante',
    );
    return '$_temp0';
  }

  @override
  String get reward_unlock_cta => 'Débloquer';

  @override
  String get rewardKind_cinema => 'Cinéma';

  @override
  String get rewardKind_concertHall => 'Salle de concert';

  @override
  String get rewardKind_theatre => 'Salle de spectacle';

  @override
  String get rewardKind_sportsMatch => 'Match de basket';

  @override
  String get rewardKind_themePark => 'Parc d\'attractions';

  @override
  String get rewardKind_other => 'Autre';

  @override
  String get rewardItem_francofoliesLaRochelle =>
      'Les francofolies de La Rochelle';

  @override
  String get rewardItem_futuroscope => 'Futuroscope';

  @override
  String get rewardItem_cinemaTicket => 'Place de cinéma';

  @override
  String get parcoursRecentActivities_title => 'Activités récentes';

  @override
  String get inviteFriends_title => 'Inviter des amis';

  @override
  String get inviteFriends_description =>
      'Dis à tes amis quapprendre avec Murya, cest simple, intelligent et récompensé.';

  @override
  String inviteFriends_bonus(int amount) {
    return 'Invite-les et gagne $amount 💎 dès leur inscription.';
  }

  @override
  String get inviteFriends_cta => 'Inviter';

  @override
  String get common_ok => 'Ok';

  @override
  String get popup_contentNotAvailable_title => 'Version de démonstration';

  @override
  String get popup_contentNotAvailable_body =>
      'Cette fonctionnalité n\'est pas accessible dans le prototype. Elle sera débloquée dans la version complète de Murya.';

  @override
  String get popup_contentNotAvailable_cta => 'Ok, c\'est compris';

  @override
  String get authLoading_title => 'Chargement...';

  @override
  String get authLoading_message_engineInit => 'Initialisation du moteur...';

  @override
  String get authLoading_message_uiArtifacts =>
      'Chargement des artefacts UI...';

  @override
  String get authLoading_message_permissionsCheck =>
      'Vérification des autorisations...';

  @override
  String get authLoading_message_modulesCompile => 'Compilation des modules...';

  @override
  String get authLoading_message_cacheSync =>
      'Synchronisation du cache local...';

  @override
  String get authLoading_message_profileFetch =>
      'Récupération du profil utilisateur...';

  @override
  String get authLoading_message_sessionPrep => 'Préparation de la session...';

  @override
  String get authLoading_message_renderOptimize => 'Optimisation du rendu...';

  @override
  String get authLoading_message_finalize => 'Finalisation...';

  @override
  String authLoading_debugLine(int percent) {
    return 'Chargement des ressources • $percent%';
  }

  @override
  String get chip_new => 'Nouveau';

  @override
  String get chip_pending => 'En attente';

  @override
  String get user_firstName_placeholder => 'Prénom';

  @override
  String get user_lastName_placeholder => 'Nom';

  @override
  String get user_anonymous_placeholder => 'Prénom Nom';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours consécutifs',
      one: 'Premier jour, beau départ !',
      zero: 'Premier jour, beau départ !',
    );
    return '$_temp0';
  }

  @override
  String get email_label => 'E-mail';

  @override
  String get email_invalid_error => 'E-mail invalide';

  @override
  String get diploma_label => 'Diplôme';

  @override
  String get diplomaYear_label => 'Promotion';

  @override
  String get diplomaSchool_label => 'Établissement';

  @override
  String get saveChanges_button => 'Enregistrer';

  @override
  String get editChanges_button => 'Modifier';
}
