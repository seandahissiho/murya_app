part of 'app_bar.dart';

class MobileCustomAppBar extends StatefulWidget {
  const MobileCustomAppBar({super.key});

  @override
  State<MobileCustomAppBar> createState() => _MobileCustomAppBarState();
}

class _MobileCustomAppBarState extends State<MobileCustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 32,
          width: 100.w,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                AppIcons.appIcon1Path,
                width: 107,
                height: 27,
              ),
              GestureDetector(
                onTap: () {
                  // rightModalOpen(context, screen: const MainSearchScreen());
                  navigateToPath(context, to: AppRoutes.searchModule);
                },
                child: SvgPicture.asset(
                  AppIcons.homeSearchIconPath,
                  width: 32,
                  height: 32,
                ),
              )
            ],
          ),
        ),
        AppSpacing.sectionMarginBox,
      ],
    );
  }
}
