part of '../profile.dart';

class TabletJourneyInfoTab extends StatefulWidget {
  const TabletJourneyInfoTab({super.key});

  @override
  State<TabletJourneyInfoTab> createState() => _TabletJourneyInfoTabState();
}

class _TabletJourneyInfoTabState extends State<TabletJourneyInfoTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: UserListBox(),
              ),
              AppSpacing.groupMarginBox,
              InvitationBox(),
              Spacer(),
            ],
          ),
        ),
        AppSpacing.groupMarginBox,
        Expanded(
          flex: 1,
          child: SizedBox(
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const UserInfoBox(),
                  AppSpacing.groupMarginBox,
                  const QuestInfoBox(),
                  AppSpacing.groupMarginBox,
                  Container(
                    constraints: const BoxConstraints(minHeight: 100, maxHeight: 500),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDefault,
                      borderRadius: AppRadius.small,
                      border: Border.all(color: AppColors.borderLight, width: 2),
                    ),
                  ),
                  AppSpacing.groupMarginBox,
                  Container(
                    constraints: const BoxConstraints(minHeight: 100, maxHeight: 500),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDefault,
                      borderRadius: AppRadius.small,
                      border: Border.all(color: AppColors.borderLight, width: 2),
                    ),
                  ),
                  AppSpacing.groupMarginBox,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UserListBox extends StatelessWidget {
  const UserListBox({super.key});

  static const double _userRowHeight = 82;

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final List<LeaderBoardUser> users = state.leaderboardUsers;
        final bool isLoading = state.leaderboardLoading;
        final int rows = users.isEmpty ? 2 : users.length + 1;
        return Container(
          height: _userRowHeight * rows,
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: AppRadius.small,
            border: Border.all(color: AppColors.borderLight, width: 2),
          ),
          child: isLoading && users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(.125),
                      1: FlexColumnWidth(.4),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                      5: FlexColumnWidth(.75),
                    },
                    children: [
                      headers(theme),
                      ...users.map((user) {
                        final int index = users.indexOf(user) + 1;
                        return userRow(user, theme, index, currentUserId: state.user.id);
                      }).toList(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  TableRow headers(ThemeData theme) {
    final List<String> headers = [
      '',
      '',
      'Personne',
      'Expérience',
      'Questions répondues',
      'Performance',
    ];
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      children: headers.map((header) {
        return TableCell(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.containerInsideMargin),
          child: Text(
            header,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ));
      }).toList(),
    );
  }

  TableRow userRow(LeaderBoardUser user, ThemeData theme, int index, {String? currentUserId}) {
    final int displayRank = user.rank > 0 ? user.rank : index;
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      children: [
        TableCell(
            child: SizedBox(
          height: _userRowHeight,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.containerInsideMarginSmall),
            alignment: Alignment.centerRight,
            child: Text(
              '$displayRank',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        )),
        TableCell(
            child: SizedBox(
          height: _userRowHeight,
          child: Center(
            child: Container(
              height: _userRowHeight / 1.75,
              width: _userRowHeight / 1.75,
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                // border: Border.all(color: AppColors.borderLight, width: 2),
                shape: BoxShape.circle,
                image: user.profilePictureUrl.isNotEmptyOrNull
                    ? DecorationImage(
                        image: NetworkImage(user.profilePictureUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: user.profilePictureUrl.isEmptyOrNull
                  ? SvgPicture.asset(
                      AppIcons.avatarPlaceholderPath,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
        )),
        TableCell(
            child: SizedBox(
          height: _userRowHeight,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.containerInsideMarginSmall),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.firstName.isEmpty ? 'Prénom' : user.firstName} ${currentUserId == user.id ? '(Vous)' : ''}",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.lastName.isEmpty ? 'Nom' : user.lastName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        )),
        TableCell(
            child: SizedBox(
          height: _userRowHeight,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.containerInsideMarginSmall),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppSpacing.elementMarginBox,
                Text(
                  '${user.diamonds}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.elementMarginBox,
                SvgPicture.asset(
                  AppIcons.diamondIconPath,
                  height: 14,
                  colorFilter: const ColorFilter.mode(AppColors.primaryFocus, BlendMode.srcIn),
                )
              ],
            ),
          ),
        )),
        TableCell(
            child: SizedBox(
          height: _userRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.containerInsideMarginSmall),
            child: Align(
              alignment: Alignment.centerLeft,
              child: user.completedQuizzes > 0
                  ? Text(
                      '${user.completedQuizzes * 10} depuis ${_formatDate(user.sinceDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    )
                  : pendingChip(theme),
            ),
          ),
        )),
        TableCell(
            child: SizedBox(
          height: _userRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.containerInsideMarginSmall),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (user.completedQuizzes > 0) AppSpacing.elementMarginBox,
                user.completedQuizzes > 0
                    ? Text(
                        '${user.percentage.toStringAsFixed(0)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      )
                    : pendingChip(theme),
              ],
            ),
          ),
        )),
      ],
    );
  }

  pendingChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.elementMargin,
        vertical: AppSpacing.tinyMargin,
      ),
      decoration: const BoxDecoration(
        // rgba(245, 163, 63, 0.2)
        color: Color.fromRGBO(245, 163, 63, 0.2),
        borderRadius: AppRadius.small,
      ),
      child: Text(
        'En attente',
        style: theme.textTheme.labelMedium?.copyWith(
          // rgba(199, 128, 40, 1)
          color: const Color.fromRGBO(199, 128, 40, 1),
        ),
      ),
    );
  }
}

class InvitationBox extends StatelessWidget {
  const InvitationBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
      padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(mainAxisSize: MainAxisSize.max, children: []),
          Text(
            "Inviter des amis",
            style: GoogleFonts.anton(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              height: 44 / 28,
              letterSpacing: -0.56,
              color: AppButtonColors.secondaryTextDefault,
            ),
          ),
          AppSpacing.groupMarginBox,
          RichText(
              text: TextSpan(
            text:
                "Dis à tes amis qu’apprendre avec Murya, c’est simple, intelligent et récompensé.\nInvite-les et gagne ",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 24 / theme.textTheme.bodyLarge!.fontSize!,
            ),
            children: [
              TextSpan(
                text: "1000 💎 ",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 24 / theme.textTheme.bodyLarge!.fontSize!,
                ),
              ),
              TextSpan(
                text: "dès leur inscription.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 24 / theme.textTheme.bodyLarge!.fontSize!,
                ),
              ),
            ],
          )),
          AppSpacing.containerInsideMarginBox,
          AppXButton(
            leftIcon: const Icon(
              Icons.person_add_alt_1_outlined,
              color: AppButtonColors.primaryTextDefault,
            ),
            text: "Inviter",
            onPressed: () {},
            isLoading: false,
          ),
        ],
      ),
    );
  }
}

class UserInfoBox extends StatelessWidget {
  const UserInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        return Container(
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.small,
            border: Border.all(color: AppColors.borderLight, width: 2),
          ),
          padding: const EdgeInsets.all(AppSpacing.containerInsideMarginSmall),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppIcons.avatarPlaceholderPath,
                  fit: BoxFit.cover,
                ),
              ),
              AppSpacing.elementMarginBox,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.firstName ?? 'Prénom',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    user.lastName ?? 'Nom',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              ScoreWidget(value: user.diamonds ?? 0),
            ],
          ),
        );
      },
    );
  }
}

class QuestInfoBox extends StatelessWidget {
  const QuestInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    const scale = 1.0;

    return LayoutBuilder(builder: (context, constraints) {
      return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final questGroup = state.questGroups.groups.firstOrNull ?? const QuestGroup();
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderMedium),
              borderRadius: AppRadius.small,
            ),
            padding: const EdgeInsets.all(AppSpacing.containerInsideMargin * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.parcoursObjective_inProgress,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14 * scale,
                  ),
                ),
                AppSpacing.tinyMarginBox,
                Flexible(
                  child: AutoSizeText(
                    (questGroup.group?.title).toString(),
                    style: theme.textTheme.labelLarge!.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: math.max(16 * scale, 2),
                    ),
                    maxFontSize: math.max(16 * scale, 2),
                    minFontSize: math.max(10 * scale, 2),
                    maxLines: 2,
                  ),
                ),
                AppSpacing.groupMarginBox,
                // Progress bar
                Stack(
                  children: [
                    Container(
                      height: 16 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(AppRadius.tinyRadius / 2 * scale),
                      ),
                    ),
                    Container(
                      height: 16 * scale,
                      width: (constraints.maxWidth - 2 * AppSpacing.containerInsideMargin * scale) *
                          (completionPercentage(questGroup)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFocus,
                        borderRadius: BorderRadius.circular(AppRadius.tinyRadius / 2 * scale),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryDefault,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
    );
  }

  completionPercentage(QuestGroup questGroup) {
    if (questGroup.requiredCompleted == 0) {
      return 0.025;
    }
    return questGroup.requiredCompleted / questGroup.requiredTotal;
  }
}
