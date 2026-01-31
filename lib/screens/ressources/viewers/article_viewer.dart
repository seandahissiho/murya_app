part of 'viewer_handler.dart';

class ArticleViewer extends StatelessWidget {
  final Resource resource;

  const ArticleViewer({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      mobileScreen: MobileArticleViewerScreen(resource: resource),
      tabletScreen: TabletArticleViewerScreen(resource: resource),
      desktopScreen: TabletArticleViewerScreen(resource: resource),
    );
  }
}

class MobileArticleViewerScreen extends StatefulWidget {
  final Resource resource;

  const MobileArticleViewerScreen({super.key, required this.resource});

  @override
  State<MobileArticleViewerScreen> createState() => _MobileArticleViewerScreenState();
}

class _MobileArticleViewerScreenState extends State<MobileArticleViewerScreen> {
  bool _readSent = false;

  @override
  void dispose() {
    _sendReadIfNeeded();
    super.dispose();
  }

  void _sendReadIfNeeded() {
    if (_readSent) return;
    final resourceId = widget.resource.id;
    if (resourceId == null || resourceId.isEmpty) return;
    if (widget.resource.userState?.readAt != null) return;
    _readSent = true;
    context.read<ResourcesBloc>().add(ReadResource(resourceId: resourceId, progress: 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final appSize = AppSize(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        AppSpacing.sectionMarginBox,
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.blue,
                  //           child: Flexible(
                  //             child: Markdown(
                  //               controller: controller,
                  //               selectable: true,
                  //               data: """
                  //           # La Voie du Product Manager : Comprendre, Prioriser et Améliorer
                  //
                  // Dans cet article, nous allons explorer dix compétences clés qui sont essentielles pour un product manager (PM) efficace. Notre objectif est d'approfondir votre compréhension de ces compétences, de vous aider à identifier les erreurs courantes et de vous fournir des exercices pratiques pour améliorer votre maîtrise.
                  //
                  // ## Conduire des Interviews
                  //
                  // Conduire des interviews permet de comprendre les besoins réels des utilisateurs. Pour être efficace, il faut poser les bonnes questions et écouter attentivement les réponses.
                  //
                  // **Exemple** : Un utilisateur exprime sa frustration face à une fonctionnalité. Au lieu de suggérer immédiatement des solutions, demandez-lui de décrire sa situation idéale. Cela peut révéler des besoins cachés.
                  //
                  // **Erreur fréquente** : Ne pas poser de questions ouvertes. Vous obtiendrez des informations plus riches en demandant "Pourquoi ?" ou "Pouvez-vous me donner un exemple ?" plutôt que des questions fermées.
                  //
                  // **Exercice** : Pratiquez vos compétences en interview en demandant à un collègue de faire semblant d'être un utilisateur et de lui poser des questions sur un problème fictif.
                  //
                  // ## Évaluer la Concurrence
                  //
                  // Évaluer la concurrence aide à mieux comprendre le marché et à identifier les opportunités.
                  //
                  // **Exemple** : Examinez les fonctionnalités, les tarifs et les avis des produits concurrents pour comprendre leurs forces et faiblesses.
                  //
                  // **Erreur fréquente** : Se concentrer uniquement sur les concurrents directs. Les concurrents indirects et les substituts potentiels peuvent également vous donner des idées.
                  //
                  // **Exercice** : Choisissez un concurrent et faites une analyse SWOT (Forces, Faiblesses, Opportunités, Menaces).
                  //
                  // ## Prioriser le Backlog
                  //
                  // Prioriser le backlog est crucial pour s'assurer que l'équipe de développement travaille sur les fonctionnalités les plus impactantes.
                  //
                  // **Exemple** : Utilisez une méthode comme le MoSCoW (Must have, Should have, Could have, Won't have) pour classer les fonctionnalités en fonction de leur importance.
                  //
                  // **Erreur fréquente** : Ne pas prendre en compte l'effort de développement lors de la priorisation. Une fonctionnalité de faible impact mais rapide à développer peut parfois être plus utile qu'une fonctionnalité de grand impact mais longue à développer.
                  //
                  // **Exercice** : Prenez votre backlog actuel et essayez de le prioriser en utilisant la méthode MoSCoW.
                  //
                  // ## Planifier les Releases
                  //
                  // Planifier les releases vous permet de communiquer clairement les attentes aux parties prenantes internes et externes.
                  //
                  // **Exemple** : Une roadmap produit sur 6-12 mois doit être réaliste, flexible et alignée avec les objectifs stratégiques de l'entreprise.
                  //
                  // **Erreur fréquente** : Surcharger la roadmap. Il est préférable d'avoir moins d'éléments et de les livrer que de ne pas tenir ses promesses.
                  //
                  // **Exercice** : Créez une roadmap fictive pour un produit, en incluant des dates de sortie, des fonctionnalités clés et des objectifs.
                  //
                  // ## Interpréter les Données
                  //
                  // Interpréter les données d'usage d'un produit vous aide à comprendre ce qui fonctionne et ce qui doit être amélioré.
                  //
                  // **Exemple** : Si les utilisateurs abandonnent une fonctionnalité à un certain point, il se peut qu'il y ait un problème à résoudre.
                  //
                  // **Erreur fréquente** : Se concentrer sur la vanité des métriques (comme le nombre total d'utilisateurs) plutôt que sur les métriques significatives (comme l'engagement des utilisateurs).
                  //
                  // **Exercice** : Examinez les données d'usage d'une fonctionnalité de votre produit et essayez de tirer des conclusions.
                  //
                  // ## Définir les Métriques
                  //
                  // Définir les bonnes métriques peut vous aider à suivre la performance d'un produit.
                  //
                  // **Exemple** : Le taux de conversion, le temps passé sur le produit ou le taux de rétention peuvent être des KPI pertinents.
                  //
                  // **Erreur fréquente** : Choisir trop de métriques. Il vaut mieux se concentrer sur quelques-unes qui sont vraiment importantes.
                  //
                  // **Exercice** : Identifiez trois KPI pour votre produit et expliquez pourquoi vous les avez choisis.
                  //
                  // ## Suivre l'Avancement
                  //
                  // Suivre l'avancement d'un projet permet de s'assurer que tout est sur la bonne voie.
                  //
                  // **Exemple** : Utilisez des outils de suivi de projet pour voir rapidement où en sont les différentes tâches.
                  //
                  // **Erreur fréquente** : Ne pas communiquer régulièrement l'avancement aux parties prenantes.
                  //
                  // **Exercice** : Mettez en place un système de rapport d'avancement pour votre projet actuel.
                  //
                  // ## Améliorer les Processus
                  //
                  // L'amélioration des processus est essentielle pour maintenir l'efficacité de l'équipe à mesure qu'elle grandit.
                  //
                  // **Exemple** : Introduisez des revues de code ou des sessions de brainstorming régulières pour améliorer la qualité et la créativité.
                  //
                  // **Erreur fréquente** : Ignorer les retours de l'équipe. Ils sont souvent les mieux placés pour savoir ce qui doit être amélioré.
                  //
                  // **Exercice** : Demandez à chaque membre de l'équipe une chose qu'ils amélioreraient dans le processus actuel.
                  //
                  // ## Porter la Vision du Produit
                  //
                  // Un bon PM doit pouvoir mobiliser efficacement les équipes, même sans autorité hiérarchique.
                  //
                  // **Exemple** : Expliquez clairement la vision du produit et comment chaque tâche contribue à cette vision.
                  //
                  // **Erreur fréquente** : Ne pas impliquer l'équipe dans l'élaboration de la vision. Ils seront plus engagés s'ils se sentent partie prenante.
                  //
                  // **Exercice** : Préparez une présentation de la vision de votre produit pour l'équipe.
                  //
                  // ## Développer les Talents
                  //
                  // Un PM expérimenté devrait aider à développer les talents de son équipe.
                  //
                  // **Exemple** : Fournir des retours constructifs et encourager les membres de l'équipe à prendre des initiatives.
                  //
                  // **Erreur fréquente** : Ne pas donner assez de responsabilités aux membres de l'équipe. Ils apprennent le mieux en faisant.
                  //
                  // **Exercice** : Identifiez une compétence que chaque membre de l'équipe pourrait développer et discutez-en avec eux.
                  //
                  // # Valorisons Vos Points Forts
                  //
                  // Félicitations, vous maîtrisez déjà ces compétences clés ! Continuez à les pratiquer et à les approfondir. N'oubliez pas que l'apprentissage est un processus continu et que vous pouvez toujours vous améliorer.
                  //
                  // # Plan d'Action pour les 7 Prochains Jours
                  //
                  // 1. Pratiquez vos compétences en interview avec un collègue.
                  // 2. Faites une analyse SWOT d'un concurrent.
                  // 3. Priorisez votre backlog en utilisant la méthode MoSCoW.
                  // 4. Créez une roadmap fictive pour un produit.
                  // 5. Examinez les données d'usage d'une fonctionnalité de votre produit.
                  // 6. Identifiez trois KPI pour votre produit.
                  // 7. Mettez en place un système de rapport d'avancement pour votre projet.
                  // 8. Demandez à chaque membre de l'équipe une chose à améliorer dans le processus.
                  // 9. Préparez une présentation de la vision de votre produit.
                  // 10. Identifiez une compétence à développer pour chaque membre de l'équipe.
                  //
                  // Bonne chance dans votre voyage pour devenir un meilleur product manager
                  //           """,
                  //             ),
                  //           ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TabletArticleViewerScreen extends StatefulWidget {
  final Resource resource;

  const TabletArticleViewerScreen({super.key, required this.resource});

  @override
  State<TabletArticleViewerScreen> createState() => _TabletArticleViewerScreenState();
}

class _TabletArticleViewerScreenState extends State<TabletArticleViewerScreen> {
  int hoveredIndex = -1;
  int selectedIndex = -1;
  final TocController tocController = TocController();
  final AutoScrollController controller = AutoScrollController();
  int currentIndex = 0;
  bool _readSent = false;

  @override
  void dispose() {
    _sendReadIfNeeded();
    super.dispose();
  }

  void _sendReadIfNeeded() {
    if (_readSent) return;
    final resourceId = widget.resource.id;
    if (resourceId == null || resourceId.isEmpty) return;
    if (widget.resource.userState?.readAt != null) return;
    _readSent = true;
    context.read<ResourcesBloc>().add(ReadResource(resourceId: resourceId, progress: 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final appSize = AppSize(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            const AppXReturnButton(destination: AppRoutes.userRessourcesModule),
            AppSpacing.groupMarginBox,
            Expanded(
              child: AppBreadcrumb(
                items: [
                  BreadcrumbItem(
                    label: AppLocalizations.of(context).mediaLibrary,
                    onTap: () => navigateToPath(context, to: AppRoutes.userRessourcesModule),
                  ),
                  BreadcrumbItem(label: widget.resource.title ?? ''),
                ],
                inactiveTextStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
                inactiveHoverTextStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryDefault, // hover
                  decoration: TextDecoration.underline, // optionnel
                ),
                activeTextStyle: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryDefault,
                ),
                scrollable: true,
              ),
            ),
            const AppXCloseButton(),
          ],
        ),
        AppSpacing.sectionMarginBox,
        Expanded(
          child: Row(
            children: [
              Expanded(
                // child: TocWidget(controller: controller),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: AppRadius.large,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
                        child: Text(AppLocalizations.of(context).summary, style: theme.textTheme.labelLarge),
                      ),
                      const Divider(
                        height: 0,
                        color: AppColors.borderMedium,
                        thickness: 1,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
                          child: TocWidget(
                            controller: tocController,
                            itemBuilder: (data) {
                              final index = data.index;
                              final toc = data.toc;
                              final node = toc.node;
                              final level = headingTag2Level[node.headingConfig.tag] ?? 1;

                              final bool isHovered = hoveredIndex == index;
                              final bool isSelected = selectedIndex == index;

                              return MouseRegion(
                                onHover: (_) {
                                  setState(() {
                                    hoveredIndex = index;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    hoveredIndex = -1;
                                  });
                                },
                                child: InkWell(
                                  onTap: () {
                                    // scroll markdown to the corresponding heading
                                    tocController.jumpToIndex(toc.widgetIndex);

                                    // update TocWidget's current index
                                    data.refreshIndexCallback(index);

                                    // your own selected state
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: (isHovered || isSelected) ? AppColors.secondaryHover : null,
                                      borderRadius: AppRadius.tiny,
                                    ),
                                    padding: const EdgeInsets.all(
                                      AppSpacing.containerInsideMarginSmall,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 12.0 * (level - 1) * 0),
                                      child: Row(
                                        children: [
                                          // bullet
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.secondaryDefault,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.borderMedium,
                                                width: 1,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(
                                                AppSpacing.elementMargin + AppSpacing.tinyTinyMargin),
                                            child: Center(
                                              child: Text((index + 1).toString()),
                                            ),
                                          ),
                                          AppSpacing.elementMarginBox,

                                          // actual heading title from markdown
                                          Expanded(
                                            child: ProxyRichText(
                                              node
                                                  .copy(
                                                    headingConfig: _TocHeadingConfig(
                                                      // use your theme style but you can switch for selected if you want
                                                      (isSelected
                                                              ? theme.textTheme.bodyLarge
                                                                  ?.copyWith(color: AppColors.textPrimary)
                                                              : theme.textTheme.bodyLarge
                                                                  ?.copyWith(color: AppColors.textPrimary)) ??
                                                          defaultTocTextStyle,
                                                      node.headingConfig.tag,
                                                    ),
                                                  )
                                                  .build(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              AppSpacing.groupMarginBox,
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: AppRadius.large,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
                        child: Text(AppLocalizations.of(context).article, style: theme.textTheme.labelLarge),
                      ),
                      const Divider(
                        height: 0,
                        color: AppColors.borderMedium,
                        thickness: 1,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
                          child: MarkdownWidget(
                            tocController: tocController,
                            data: widget.resource.content ?? '',
                            // selectable: true,
                            // data: widget.resource.content ?? '',
//                             data: """
// # Maîtriser le rôle de Product Manager
//
// Un Product Manager (PM) est un peu comme le chef d'orchestre d'une symphonie. Il ne joue pas d'instrument, mais il est responsable de l'harmonie d'ensemble. Il a la vision du produit, comprend les besoins du marché et des utilisateurs, et sait comment orchestrer les différentes équipes pour transformer cette vision en réalité.
//
// ## Une journée dans la vie d'un PM
//
// Imaginez que vous êtes un PM, vous commencez votre journée par une revue du tableau de bord du produit. Vous vérifiez les métriques clés, analysez les données d'utilisation et évaluez l'impact des dernières mises à jour. Vous avez également une réunion avec l'équipe de développement pour discuter de l'avancement des fonctionnalités en cours et pour prioriser le backlog. L'après-midi, vous organisez une session de brainstorming avec l'équipe de design pour discuter des améliorations de l'interface utilisateur. Enfin, vous terminez votre journée en préparant une présentation pour le comité exécutif pour partager la vision du produit et les prochaines étapes.
//
// ## Analyse de vos compétences
//
// Récemment, vous avez passé une évaluation de vos compétences en tant que PM. Bravo pour votre score parfait ! Cela démontre une solide compréhension des différentes facettes du rôle. Vous savez comment conduire des interviews pour comprendre les besoins des utilisateurs, évaluer la concurrence, prioriser le backlog, planifier les releases, interpréter les données, définir les métriques, suivre l'avancement, améliorer les processus, porter la vision du produit et développer les talents de votre équipe.
//
// ## Pistes d'amélioration
//
// Cependant, même avec un score parfait, il y a toujours de la place pour l'amélioration. Par exemple, pour conduire des interviews, essayez de poser des questions ouvertes qui encouragent les utilisateurs à partager leurs expériences, plutôt que d'obtenir des réponses oui/non. Pour évaluer la concurrence, n'oubliez pas de prendre en compte les startups et les produits en phase de lancement, pas seulement les grands acteurs établis. Pour interpréter les données, essayez de trouver des tendances et des modèles, et n'oubliez pas de prendre en compte le contexte dans lequel les données ont été collectées.
//
// ## Plan d'action
//
// Pour continuer à progresser en tant que PM, je vous propose quelques actions. Tout d'abord, essayez de passer plus de temps avec les utilisateurs pour comprendre leurs besoins et leurs défis. Ensuite, restez à jour sur les tendances du marché et de l'industrie, en participant par exemple à des conférences et en lisant des blogs spécialisés. Enfin, essayez de trouver un mentor qui a plus d'expérience en tant que PM, il pourra vous donner des conseils précieux et partager ses expériences.
//
// En conclusion, le rôle de PM est complexe et multidimensionnel, mais avec la bonne approche et les bonnes compétences, vous pouvez mener votre produit à la réussite. Alors, prêt à diriger votre symphonie ?
//                               """,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TocHeadingConfig extends HeadingConfig {
  @override
  final TextStyle style;
  @override
  final String tag;

  _TocHeadingConfig(this.style, this.tag);
}
