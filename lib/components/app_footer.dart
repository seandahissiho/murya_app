import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/components/dropdown.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/localization/locale_controller.dart';
import 'package:murya/models/country.dart';
import 'package:murya/screens/base.dart';
import 'package:provider/provider.dart';

class AppFooter extends StatelessWidget {
  final bool isLanding;

  const AppFooter({super.key, this.isLanding = false});

  @override
  Widget build(BuildContext context) {
    if (!isLanding) {
      return Container();
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          decoration: const BoxDecoration(
            color: AppColors.backgroundHover,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.largeRadius)),
          ),
          child: const BaseScreen(
            mobileScreen: MobileAppFooter(),
            tabletScreen: TabletAppFooter(),
            desktopScreen: TabletAppFooter(),
            useBackgroundColor: false,
            noPadding: true,
          ),
        ),
        AppSpacing.pageMarginBox,
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}

class MobileAppFooter extends StatefulWidget {
  const MobileAppFooter({super.key});

  @override
  State<MobileAppFooter> createState() => _MobileAppFooterState();
}

class _MobileAppFooterState extends State<MobileAppFooter> {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final local = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppXDropdown(
                key: const Key('language-dropdown'),
                shrinkWrap: true,
                controller: TextEditingController(text: state.language.code != 'fr' ? 'English' : 'Français'),
                // DropdownMenuEntry
                items: [
                  DropdownMenuEntry(
                    value: 'fr',
                    label: 'Français',
                    leadingIcon: SvgPicture.asset(AppIcons.frLanguageIconPath),
                    trailingIcon: state.language.code == 'fr'
                        ? SvgPicture.asset(
                            AppIcons.doneCheckPath,
                            width: 16,
                            height: 16,
                          )
                        : null,
                  ),
                  DropdownMenuEntry(
                    value: 'en',
                    label: 'English',
                    leadingIcon: SvgPicture.asset(AppIcons.enLanguageIconPath),
                    trailingIcon: state.language.code == 'en'
                        ? SvgPicture.asset(
                            AppIcons.doneCheckPath,
                            width: 16,
                            height: 16,
                          )
                        : null,
                  ),
                ],
                onSelected: (value) {
                  if (value == null) return;
                  final locale = Locale(value);
                  localeProvider.set(locale);
                  // onLocaleChange(context);
                  context.read<AppBloc>().add(
                        AppChangeLanguage(
                          language: value == 'fr' ? AppLanguage.english : AppLanguage.french,
                          context: context,
                        ),
                      );
                },
              ),
              AppSpacing.spacing16_Box,
              TextWithLinks(
                textsLinks: [
                  TextLink(
                      text: '${local.footer_legal_mentions} · ',
                      isLink: false,
                      onTap: () {
                        // navigateToPath(context, to: AppRoutes.legalMentions);
                      }),
                  TextLink(
                      text: '${local.footer_privacy_policy} · ',
                      isLink: false,
                      onTap: () {
                        // navigateToPath(context, to: AppRoutes.privacyPolicy);
                      }),
                  TextLink(
                      text: '${local.footer_cookie_settings} · ',
                      isLink: false,
                      onTap: () {
                        // navigateToPath(context, to: AppRoutes.cookieSettings);
                      }),
                  TextLink(
                      text: local.footer_accessibility,
                      isLink: false,
                      onTap: () {
                        // navigateToPath(context, to: AppRoutes.accessibility);
                      }),
                ],
                textStyleText: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: theme.textTheme.bodySmall!.fontSize,
                  fontWeight: FontWeight.w400,
                ),
                textStyleLink: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: theme.textTheme.bodySmall!.fontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
              AppSpacing.spacing16_Box,
              Text(
                local.footer_copyright,
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: theme.textTheme.bodySmall!.fontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TabletAppFooter extends StatefulWidget {
  const TabletAppFooter({super.key});

  @override
  State<TabletAppFooter> createState() => _TabletAppFooterState();
}

class _TabletAppFooterState extends State<TabletAppFooter> {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final local = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppXDropdown(
                shrinkWrap: true,
                leftIconPath: state.language.code != 'fr' ? AppIcons.enLanguageIconPath : AppIcons.frLanguageIconPath,
                // leftIcon: SvgPicture.asset(
                //     state.language.code != 'fr' ? AppIcons.enLanguageIconPath : AppIcons.frLanguageIconPath),
                // maxDropdownWidth: 110,
                controller: TextEditingController(text: state.language.code != 'fr' ? 'English' : 'Français'),
                items: [
                  DropdownMenuEntry(
                    value: 'fr',
                    label: 'Français',
                    leadingIcon: SvgPicture.asset(AppIcons.frLanguageIconPath),
                    trailingIcon: state.language.code == 'fr'
                        ? SvgPicture.asset(
                            AppIcons.doneCheckPath,
                            width: 16,
                            height: 16,
                          )
                        : null,
                  ),
                  DropdownMenuEntry(
                    value: 'en',
                    label: 'English',
                    leadingIcon: SvgPicture.asset(AppIcons.enLanguageIconPath),
                    trailingIcon: state.language.code == 'en'
                        ? SvgPicture.asset(
                            AppIcons.doneCheckPath,
                            width: 16,
                            height: 16,
                          )
                        : null,
                  ),
                ],
                onSelected: (value) {
                  if (value == null) return;
                  final locale = Locale(value);
                  localeProvider.set(locale);
                  // onLocaleChange(context);
                  context.read<AppBloc>().add(
                        AppChangeLanguage(
                          language: value == 'fr' ? AppLanguage.french : AppLanguage.english,
                          context: context,
                        ),
                      );
                },
              ),
              AppSpacing.spacing16_Box,
              TextWithLinks(
                textsLinks: [
                  TextLink(
                      text: '${local.footer_legal_mentions} · ',
                      isLink: false,
                      onTap: () {
                        // navigateToPath(context, to: AppRoutes.legalMentions);
                      }),
                  TextLink(
                      text: '${local.footer_privacy_policy} · ',
                      isLink: false,
                      onTap: () {
                        // navigateToPath(context, to: AppRoutes.privacyPolicy);
                      }),
                  TextLink(
                      text: '${local.footer_cookie_settings} · ',
                      isLink: false,
                      onTap: () {
                        // navigateToPath(context, to: AppRoutes.cookieSettings);
                      }),
                  TextLink(
                      text: local.footer_accessibility,
                      isLink: false,
                      onTap: () {
                        // navigateToPath(context, to: AppRoutes.accessibility);
                      }),
                ],
                textStyleText: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: theme.textTheme.bodySmall!.fontSize,
                  fontWeight: FontWeight.w400,
                ),
                textStyleLink: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: theme.textTheme.bodySmall!.fontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
              AppSpacing.spacing16_Box,
              Text(
                local.footer_copyright,
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: theme.textTheme.bodySmall!.fontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
