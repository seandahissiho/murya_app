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
          height: mobileCTAHeight,
          width: 100.w,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: mobileCTAHeight - 5,
                child: SvgPicture.asset(
                  AppIcons.appIcon1Path,
                  width: 107,
                  height: mobileCTAHeight,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // rightModalOpen(context, screen: const MainSearchScreen());
                  // navigateToPath(context, to: AppRoutes.jobModule);
                },
                child: SvgPicture.asset(
                  AppIcons.homeSearchIconPath,
                  width: mobileCTAHeight,
                  height: mobileCTAHeight,
                ),
              )
            ],
          ),
        ),
        AppSpacing.groupMarginBox,
      ],
    );
  }
}
