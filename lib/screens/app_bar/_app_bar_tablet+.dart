part of 'app_bar.dart';

class DesktopCustomAppBar extends StatefulWidget {
  const DesktopCustomAppBar({super.key});

  @override
  State<DesktopCustomAppBar> createState() => _DesktopCustomAppBarState();
}

class _DesktopCustomAppBarState extends State<DesktopCustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Column(
      children: [
        SizedBox(
          height: 40,
          width: 100.w,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 30,
                child: SvgPicture.asset(
                  AppIcons.appIcon1Path,
                  width: 161,
                  height: 40,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    // rightModalOpen(context, screen: const MainSearchScreen());
                    navigateToPath(context, to: AppRoutes.searchModule);
                  },
                  child: SvgPicture.asset(
                    AppIcons.homeSearchIconPath,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.pageMarginBox,
      ],
    );
  }
}

void rightModalOpen(BuildContext context, {required Widget screen}) {
  Navigator.of(context).push(FullScreenModalRoute(
      child: Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: screen,
  )));
}
