part of 'app_bar.dart';

class DesktopCustomAppBar extends StatefulWidget {
  const DesktopCustomAppBar({super.key});

  @override
  State<DesktopCustomAppBar> createState() => _DesktopCustomAppBarState();
}

class _DesktopCustomAppBarState extends State<DesktopCustomAppBar> {
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const Duration _animationDuration = Duration(milliseconds: 1600);
  static const Curve _animationCurve = Curves.easeInOutBack;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          return SizedBox(
            height: tabletAndAboveCTAHeight,
            width: maxWidth,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: _animationDuration,
                  curve: _animationCurve,
                  left: 0,
                  child: AnimatedOpacity(
                    duration: _animationDuration,
                    opacity: isSearching ? 0 : 1,
                    child: SizedBox(
                      height: tabletAndAboveCTAHeight - 10,
                      child: SvgPicture.asset(
                        AppIcons.appIcon1Path,
                        width: 161,
                        height: tabletAndAboveCTAHeight,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _animationDuration,
                  right: isSearching ? maxWidth - 320 : 0,
                  curve: _animationCurve,
                  child: Hero(
                    tag: 'main-search-bar',
                    child: SizedBox(
                      width: 320,
                      child: AppXTextFormField(
                        focusNode: _searchFocusNode,
                        readOnly: !isSearching,
                        disabled: false,
                        onTap: isSearching
                            ? null
                            : () async {
                                context.read<JobBloc>().add(SearchJobs(query: "", context: context));
                                setState(() {
                                  isSearching = true;
                                });
                                await Future.delayed(_animationDuration);
                                if (!mounted) return;
                                navigateToPath(context, to: AppRoutes.jobModule);
                              },
                        controller: _searchController,
                        labelText: null,
                        hintText: locale.search_placeholder,
                        prefixIconPath: AppIcons.homeSearchIcon2Path,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        AppSpacing.spacing40_Box,
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
