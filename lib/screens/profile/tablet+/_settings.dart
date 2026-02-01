part of '../profile.dart';

class TabletJourneySettingsTab extends StatefulWidget {
  const TabletJourneySettingsTab({super.key});

  @override
  State<TabletJourneySettingsTab> createState() => _TabletJourneySettingsTabState();
}

class _TabletJourneySettingsTabState extends State<TabletJourneySettingsTab> {
  User? _currentUser;

  bool modificationEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<ProfileBloc>().state;
      _currentUser = state.user;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        _currentUser ??= state.user;
        setState(() {});
      },
      builder: (context, state) {
        return AppSkeletonizer(
          enabled: _currentUser == null,
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppSpacing.spacing16_Box,
                Text(
                  locale.profile_account_title,
                  // font-family: Anton;
                  // font-style: Regular;
                  style: GoogleFonts.anton(
                    color: AppColors.textPrimary,
                    // font-size: 32px;
                    fontSize: theme.textTheme.headlineSmall?.fontSize,
                    // font-weight: 400;
                    fontWeight: FontWeight.w400,
                    // letter-spacing: -2%;
                    letterSpacing: -0.02,
                    // line-height: 38px;
                    height: 38 / (theme.textTheme.headlineSmall?.fontSize ?? 38),
                    // vertical-align: middle;
                    textBaseline: TextBaseline.alphabetic,
                    // leading-trim: NONE;
                    textStyle: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
                  ),
                ),
                AppSpacing.spacing24_Box,
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 94,
                      height: 94,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderMedium, width: 1),
                      ),
                    ),
                    AppSpacing.spacing16_Box,
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.user.contextName(context),
                          // font-family: Inter;
                          // font-weight: 600;
                          // font-style: Semi Bold;
                          // font-size: 20px;
                          // line-height: 34px;
                          // letter-spacing: -2%;
                          style: theme.textTheme.displayMedium!.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.02,
                            height: 34 / (theme.textTheme.displayMedium?.fontSize ?? 34),
                            // leading-trim: CAP_HEIGHT;
                            leadingDistribution: TextLeadingDistribution.proportional,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: ScoreWidget(value: state.user.diamonds, reverse: true, iconSize: 24),
                              ),
                            ),
                            AppSpacing.spacing4_Box,
                            // Streak widget
                            SizedBox(
                              height: 24,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: StreakWidget(streakDays: state.user.streakDays, iconSize: 24),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                AppSpacing.spacing24_Box,
                Container(
                  constraints: const BoxConstraints(maxWidth: 864),
                  child: TabletJourneySettingsForm(
                      user: _currentUser ?? User.empty(),
                      onUserChanged: (updatedUser) {
                        _currentUser = updatedUser;
                      },
                      modificationEnabled: modificationEnabled),
                ),
                AppSpacing.spacing40_Box,
                Builder(
                  builder: (formContext) {
                    return AppXButton(
                      text: modificationEnabled == false ? locale.editChanges_button : locale.saveChanges_button,
                      onPressed: () {
                        if (modificationEnabled == false) {
                          // Enable modification
                          setState(() {
                            modificationEnabled = true;
                          });
                          return;
                        }
                        if ((Form.of(formContext).validate() ?? false) == false) {
                          return;
                        }
                        // Save changes
                        if (_currentUser != null) {
                          context.read<ProfileBloc>().add(ProfileUpdateEvent(user: _currentUser!));
                          setState(() {
                            modificationEnabled = false;
                          });
                        }
                      },
                      isLoading: state is ProfileLoading,
                      shadowColor: AppColors.borderMedium,
                      bgColor: AppColors.backgroundColor,
                      fgColor: AppColors.textPrimary,
                      borderColor: AppColors.borderMedium,
                      hoverColor: AppButtonColors.secondarySurfaceHover,
                      onPressedColor: AppButtonColors.secondarySurfacePressed,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TabletJourneySettingsForm extends StatefulWidget {
  final User user;
  final bool modificationEnabled;
  final Function(User updatedUser) onUserChanged;

  const TabletJourneySettingsForm(
      {super.key, required this.user, required this.onUserChanged, this.modificationEnabled = false});

  @override
  State<TabletJourneySettingsForm> createState() => _TabletJourneySettingsFormState();
}

class _TabletJourneySettingsFormState extends State<TabletJourneySettingsForm> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  Diploma selectedDiploma = Diploma.btsCielOptionA;
  DiplomaYear selectedDiplomaYear = DiplomaYear.firstYear;
  DiplomaSchool selectedDiplomaSchool = DiplomaSchool.lp2i;

  @override
  void initState() {
    firstNameController.text = widget.user.firstName ?? "";
    lastNameController.text = widget.user.lastName ?? "";
    emailController.text = widget.user.email ?? "";
    selectedDiploma = widget.user.diploma ?? Diploma.btsCielOptionA;
    selectedDiplomaYear = widget.user.diplomaYear ?? DiplomaYear.firstYear;
    selectedDiplomaSchool = widget.user.diplomaSchool ?? DiplomaSchool.lp2i;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppXTextFormField(
                disabled: widget.modificationEnabled == false,
                controller: firstNameController,
                labelText: locale.user_firstName_placeholder,
                hintText: locale.user_firstName_placeholder,
                onFocusChanged: (hasFocus) {
                  if (!hasFocus) {
                    widget.onUserChanged(
                      widget.user.copyWith(firstName: firstNameController.text),
                    );
                  }
                },
                onSubmitted: (value) {
                  widget.onUserChanged(
                    widget.user.copyWith(firstName: firstNameController.text),
                  );
                },
                onEditingComplete: () {
                  widget.onUserChanged(
                    widget.user.copyWith(firstName: firstNameController.text),
                  );
                },
              ),
            ),
            AppSpacing.spacing16_Box,
            Expanded(
              child: AppXTextFormField(
                disabled: widget.modificationEnabled == false,
                controller: lastNameController,
                labelText: locale.user_lastName_placeholder,
                hintText: locale.user_lastName_placeholder,
                onFocusChanged: (hasFocus) {
                  if (!hasFocus) {
                    widget.onUserChanged(
                      widget.user.copyWith(lastName: lastNameController.text),
                    );
                  }
                },
                onSubmitted: (value) {
                  widget.onUserChanged(
                    widget.user.copyWith(lastName: lastNameController.text),
                  );
                },
                onEditingComplete: () {
                  widget.onUserChanged(
                    widget.user.copyWith(lastName: lastNameController.text),
                  );
                },
              ),
            ),
          ],
        ),
        AppSpacing.spacing16_Box,
        AppXTextFormField(
          disabled: widget.modificationEnabled == false,
          controller: emailController,
          labelText: locale.email_label,
          hintText: "mail@mail.com",
          validator: (value) {
            // Can be null or empty
            if (value == null || value.isEmpty) {
              return null;
            }
            // Best email regex ever
            final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
            if (!emailRegex.hasMatch(value)) {
              return locale.email_invalid_error;
            }
            return null;
          },
          onFocusChanged: (hasFocus) {
            if (!hasFocus) {
              // Validate email on focus lost
              final result = Form.of(context).validate();
              if (result) {
                widget.onUserChanged(
                  widget.user.copyWith(email: emailController.text),
                );
              }
            }
          },
        ),
        AppSpacing.spacing16_Box,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppXDropdown<dynamic>(
                      disabled: widget.modificationEnabled == false,
                      labelInside: false,
                      labelText: locale.diploma_label,
                      controller: TextEditingController(text: selectedDiploma.displayName),
                      items: Diploma.values.map((element) {
                        return _dropDownItem(element, element.displayName);
                      }),
                      onSelected: (value) {
                        setState(() {
                          selectedDiploma = value as Diploma;
                        });
                        widget.onUserChanged(
                          widget.user.copyWith(diploma: selectedDiploma),
                        );
                      },
                    ),
                  ),
                  AppSpacing.spacing16_Box,
                  Expanded(
                    child: AppXDropdown<dynamic>(
                      disabled: widget.modificationEnabled == false,
                      labelInside: false,
                      labelText: locale.diplomaYear_label,
                      controller: TextEditingController(text: selectedDiplomaYear.displayName),
                      items: DiplomaYear.values.map((element) {
                        return _dropDownItem(element, element.displayName);
                      }),
                      onSelected: (value) {
                        setState(() {
                          selectedDiplomaYear = value as DiplomaYear;
                        });
                        widget.onUserChanged(
                          widget.user.copyWith(diplomaYear: selectedDiplomaYear),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.spacing16_Box,
            Expanded(
              flex: 1,
              child: AppXDropdown<dynamic>(
                disabled: widget.modificationEnabled == false,
                labelInside: false,
                labelText: locale.diplomaSchool_label,
                controller: TextEditingController(text: selectedDiplomaSchool.displayName),
                items: DiplomaSchool.values.map((element) {
                  return _dropDownItem(element, element.displayName);
                }),
                onSelected: (value) {
                  setState(() {
                    selectedDiplomaSchool = value as DiplomaSchool;
                  });
                  widget.onUserChanged(
                    widget.user.copyWith(diplomaSchool: selectedDiplomaSchool),
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  DropdownMenuEntry _dropDownItem(dynamic value, String label) {
    return DropdownMenuEntry<dynamic>(value: value, label: label);
  }
}
