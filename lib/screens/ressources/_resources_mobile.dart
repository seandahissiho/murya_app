part of 'resources.dart';

class MobileResourcesScreen extends StatefulWidget {
  const MobileResourcesScreen({super.key});

  @override
  State<MobileResourcesScreen> createState() => _MobileResourcesScreenState();
}

class _MobileResourcesScreenState extends State<MobileResourcesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ResourcesBloc, ResourcesState>(
      listener: (context, state) async {
        setState(() {});
        if (state is ResourceDetailsLoaded) {
          return await contentNotAvailablePopup(context);
          navigateToPath(context,
              to: AppRoutes.userResourceViewerModule.replaceFirst(
                ':id',
                state.resource.id!,
              ));
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            const Row(
              children: [
                Spacer(),
                AppXCloseButton(),
              ],
            ),
            AppSpacing.groupMarginBox,
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: AppLocalizations.of(context).page_title_resources,
                    style: GoogleFonts.anton(
                      color: AppColors.textPrimary,
                      fontSize: theme.textTheme.headlineMedium?.fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.sectionMarginBox,
            Expanded(
              child: SingleChildScrollView(
                child: AppSkeletonizer(
                  enabled: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: AppLocalizations.of(context).section_articles,
                              style: GoogleFonts.anton(
                                color: AppColors.textPrimary,
                                fontSize: theme.textTheme.headlineSmall?.fontSize,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.groupMarginBox,
                      ResourcesCarousel(
                        resources: context.read<ResourcesBloc>().articles,
                        type: ResourceType.article,
                      ),
                      AppSpacing.containerInsideMarginBox,
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: AppLocalizations.of(context).section_podcasts,
                              style: GoogleFonts.anton(
                                color: AppColors.textPrimary,
                                fontSize: theme.textTheme.headlineSmall?.fontSize,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.groupMarginBox,
                      ResourcesCarousel(
                        resources: context.read<ResourcesBloc>().podcasts,
                        type: ResourceType.podcast,
                      ),
                      AppSpacing.containerInsideMarginBox,
                      // Videos Section
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: AppLocalizations.of(context).section_videos,
                              style: GoogleFonts.anton(
                                color: AppColors.textPrimary,
                                fontSize: theme.textTheme.headlineSmall?.fontSize,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.groupMarginBox,
                      ResourcesCarousel(
                        resources: context.read<ResourcesBloc>().videos,
                        type: ResourceType.video,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
