import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
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
          padding: const EdgeInsets.all(AppSpacing.containerInsideMarginSmall),
          decoration: const BoxDecoration(
            color: AppColors.backgroundHover,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.largeRadius)),
          ),
          child: const BaseScreen(
            mobileScreen: MobileAppFooter(),
            tabletScreen: TabletAppFooter(),
            desktopScreen: TabletAppFooter(),
            useBackgroundColor: false,
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
              AppXButton(
                onPressed: () {
                  final value = state.language.code == 'fr' ? 'en' : 'fr';
                  final locale = Locale(value);
                  localeProvider.set(locale);
                  // onLocaleChange(context);
                  context.read<AppBloc>().add(
                        AppChangeLanguage(
                          language: state.language.code == 'fr' ? AppLanguage.english : AppLanguage.french,
                          context: context,
                        ),
                      );
                },
                isLoading: false,
                // leftIconPath: state.language.code == 'fr' ? AppIcons.enLanguageIconPath : AppIcons.frLanguageIconPath,
                text: state.language.code == 'fr' ? '🇬🇧 English' : '🇫🇷 Français',
                borderColor: AppColors.primary,
                bgColor: Colors.transparent,
                fgColor: AppColors.primary,
                onPressedColor: AppColors.primary.withAlpha(50),
              ),
              AppSpacing.groupMarginBox,
              TextWithLinks(
                textsLinks: [
                  TextLink(
                      text: '${local.footer_legal_mentions} · ',
                      isLink: true,
                      onTap: () {
                        navigateToPath(context, to: AppRoutes.legalMentions);
                      }),
                  TextLink(
                      text: '${local.footer_privacy_policy} · ',
                      isLink: true,
                      onTap: () {
                        navigateToPath(context, to: AppRoutes.privacyPolicy);
                      }),
                  TextLink(
                      text: '${local.footer_cookie_settings} · ',
                      isLink: true,
                      onTap: () {
                        navigateToPath(context, to: AppRoutes.cookieSettings);
                      }),
                  TextLink(
                      text: local.footer_accessibility,
                      isLink: true,
                      onTap: () {
                        navigateToPath(context, to: AppRoutes.accessibility);
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
              AppSpacing.groupMarginBox,
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
              AppXButton(
                onPressed: () {
                  final value = state.language.code == 'fr' ? 'en' : 'fr';
                  final locale = Locale(value);
                  localeProvider.set(locale);
                  // onLocaleChange(context);
                  context.read<AppBloc>().add(
                        AppChangeLanguage(
                          language: state.language.code == 'fr' ? AppLanguage.english : AppLanguage.french,
                          context: context,
                        ),
                      );
                },
                isLoading: false,
                // leftIconPath: state.language.code == 'fr' ? AppIcons.enLanguageIconPath : AppIcons.frLanguageIconPath,
                text: state.language.code == 'fr' ? '🇬🇧 English' : '🇫🇷 Français',
                borderColor: AppColors.primary,
                bgColor: Colors.transparent,
                fgColor: AppColors.primary,
                onPressedColor: AppColors.primary.withAlpha(50),
              ),
              AppSpacing.groupMarginBox,
              TextWithLinks(
                textsLinks: [
                  TextLink(
                      text: '${local.footer_legal_mentions} · ',
                      isLink: true,
                      onTap: () {
                        navigateToPath(context, to: AppRoutes.legalMentions);
                      }),
                  TextLink(
                      text: '${local.footer_privacy_policy} · ',
                      isLink: true,
                      onTap: () {
                        navigateToPath(context, to: AppRoutes.privacyPolicy);
                      }),
                  TextLink(
                      text: '${local.footer_cookie_settings} · ',
                      isLink: true,
                      onTap: () {
                        navigateToPath(context, to: AppRoutes.cookieSettings);
                      }),
                  TextLink(
                      text: local.footer_accessibility,
                      isLink: true,
                      onTap: () {
                        navigateToPath(context, to: AppRoutes.accessibility);
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
              AppSpacing.groupMarginBox,
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
