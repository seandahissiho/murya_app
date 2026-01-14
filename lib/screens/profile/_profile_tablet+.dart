part of 'profile.dart';

class TabletProfileScreen extends StatefulWidget {
  const TabletProfileScreen({super.key});

  @override
  State<TabletProfileScreen> createState() => _TabletProfileScreenState();
}

class _TabletProfileScreenState extends State<TabletProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        setState(() {});
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
                    children: [],
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
