part of 'resources.dart';

class TabletResourcesScreen extends StatefulWidget {
  const TabletResourcesScreen({super.key});

  @override
  State<TabletResourcesScreen> createState() => _TabletResourcesScreenState();
}

class _TabletResourcesScreenState extends State<TabletResourcesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                navigateToPath(context, to: AppRoutes.landing);
              },
              child: SvgPicture.asset(
                AppIcons.searchBarCloseIconPath,
                width: mobileCTAHeight,
                height: mobileCTAHeight,
              ),
            ),
          ],
        ),
        AppSpacing.groupMarginBox,
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: "Ressources",
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
                          text: "Articles",
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
                  ResourcesCarousel(resources: [
                    Resource.empty(),
                    Resource.empty(),
                    Resource.empty(),
                    Resource.empty(),
                  ], type: ResourceType.article),
                  AppSpacing.containerInsideMarginBox,
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Podcasts",
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
                  ResourcesCarousel(resources: [
                    Resource.empty(),
                    Resource.empty(),
                    Resource.empty(),
                    Resource.empty(),
                  ], type: ResourceType.podcast),
                  AppSpacing.containerInsideMarginBox,
                  // Videos Section
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Videos",
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
                  ResourcesCarousel(resources: [
                    Resource.empty(),
                    Resource.empty(),
                    Resource.empty(),
                    Resource.empty(),
                  ], type: ResourceType.video),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
