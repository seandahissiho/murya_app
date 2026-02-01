part of '../profile.dart';

class TabletJourneyInfoTab extends StatefulWidget {
  const TabletJourneyInfoTab({super.key});

  @override
  State<TabletJourneyInfoTab> createState() => _TabletJourneyInfoTabState();
}

class _TabletJourneyInfoTabState extends State<TabletJourneyInfoTab> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InvitationBox(),
              AppSpacing.spacing16_Box,
              Expanded(
                flex: 4,
                child: UserListBox(),
              ),
            ],
          ),
        ),
        AppSpacing.spacing16_Box,
        Expanded(
          flex: 1,
          child: SizedBox(
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  UserInfoBox(),
                  AppSpacing.spacing16_Box,
                  QuestInfoBox(),
                  AppSpacing.spacing16_Box,
                  PossibleRewardsBox(),
                  AppSpacing.spacing16_Box,
                  RecentActivitiesBox(),
                  AppSpacing.spacing16_Box,
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

  static const double _userRowHeight = 80;

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
    final AppLocalizations locale = AppLocalizations.of(context);
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
              : Column(
                  children: [
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1 + .4 + .125),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(.75),
                      },
                      children: [
                        headers(theme, locale, users.length),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        // physics: const NeverScrollableScrollPhysics(),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(.4),
                            1: FlexColumnWidth(1.125),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                            4: FlexColumnWidth(.75),
                          },
                          children: [
                            ...users.map((user) {
                              final int index = users.indexOf(user) + 1;
                              return userRow(user, theme, locale, index,
                                  currentUserId: state.user.id, isLast: index == users.length);
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  TableRow headers(ThemeData theme, AppLocalizations locale, int length) {
    final List<String> headers = [
      "  ${locale.parcoursRanking_peopleCount(length)}",
      locale.parcoursRanking_header_experience,
      locale.parcoursRanking_header_answeredQuestions,
      locale.parcoursRanking_header_performance,
    ];
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      children: headers.asMap().entries.map((entry) {
        final int index = entry.key;
        final String header = entry.value;
        return TableCell(
            child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.spacing24,
            horizontal: index == 0 ? AppSpacing.spacing24 : 0,
          ),
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

  TableRow userRow(LeaderBoardUser user, ThemeData theme, AppLocalizations locale, int index,
      {String? currentUserId, bool isLast = false}) {
    final int displayRank = user.rank > 0 ? user.rank : index;
    final String youTag = currentUserId == user.id ? ' ${locale.parcoursRanking_youTag}' : '';
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : const BorderSide(color: AppColors.borderLight),
        ),
      ),
      children: [
        // TableCell(
        //     child: SizedBox(
        //   height: _userRowHeight,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(vertical: AppSpacing.containerInsideMarginSmall),
        //     alignment: Alignment.centerRight,
        //     child: Text(
        //       '$displayRank',
        //       style: theme.textTheme.bodyMedium?.copyWith(
        //         color: AppColors.textPrimary,
        //       ),
        //     ),
        //   ),
        // )),
        TableCell(
            child: SizedBox(
          height: _userRowHeight,
          child: Center(
            child: Container(
              height: _userRowHeight / 1.75,
              width: _userRowHeight / 1.75,
              decoration: const BoxDecoration(
                color: AppColors.backgroundCard,
                // border: Border.all(color: AppColors.borderLight, width: 2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: user.profilePictureUrl.isEmptyOrNull
                  ? SvgPicture.asset(
                      AppIcons.avatarPlaceholderPath,
                      fit: BoxFit.cover,
                    )
                  : ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.profilePictureUrl!,
                        fit: BoxFit.cover,
                        width: _userRowHeight / 1.75,
                        height: _userRowHeight / 1.75,
                        placeholder: (context, url) {
                          return SvgPicture.asset(
                            AppIcons.avatarPlaceholderPath,
                            fit: BoxFit.cover,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return SvgPicture.asset(
                            AppIcons.avatarPlaceholderPath,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
            ),
          ),
        )),
        TableCell(
            child: SizedBox(
          height: _userRowHeight,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.firstName.isEmpty ? locale.user_firstName_placeholder : user.firstName}$youTag",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.lastName.isEmpty ? locale.user_lastName_placeholder : user.lastName,
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
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppSpacing.spacing8_Box,
                Text(
                  '${user.diamonds}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.spacing8_Box,
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
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: user.completedQuizzes > 0
                  ? Text(
                      locale.parcoursRanking_answeredSince(
                        user.completedQuizzes * 10,
                        _formatDate(user.sinceDate),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    )
                  : pendingChip(theme, locale.parcoursRanking_status_pending),
            ),
          ),
        )),
        TableCell(
            child: SizedBox(
          height: _userRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (user.completedQuizzes > 0) AppSpacing.spacing8_Box,
                user.completedQuizzes > 0
                    ? Text(
                        '${user.percentage.toStringAsFixed(0)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      )
                    : pendingChip(theme, locale.parcoursRanking_status_pending),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget pendingChip(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing8,
        vertical: AppSpacing.spacing4,
      ),
      decoration: const BoxDecoration(
        // rgba(245, 163, 63, 0.2)
        color: Color.fromRGBO(245, 163, 63, 0.2),
        borderRadius: AppRadius.small,
      ),
      child: Text(
        text,
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
    final AppLocalizations locale = AppLocalizations.of(context);
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
      padding: const EdgeInsets.all(AppSpacing.spacing12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.inviteFriends_title,
                  style: GoogleFonts.anton(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    height: 44 / 28,
                    letterSpacing: -0.56,
                    color: AppButtonColors.secondaryTextDefault,
                  ),
                ),
                AppSpacing.spacing4_Box,
                RichText(
                  text: TextSpan(
                    text: locale.inviteFriends_bonus(500),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 24 / theme.textTheme.bodyLarge!.fontSize!,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.spacing24_Box,
          AppXButton(
            leftIcon: const Icon(
              Icons.person_add_alt_1_outlined,
              color: AppButtonColors.primaryTextDefault,
            ),
            text: locale.inviteFriends_cta,
            onPressed: () async {
              return await contentNotAvailablePopup(context);
            },
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
    final AppLocalizations locale = AppLocalizations.of(context);
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
          padding: const EdgeInsets.all(AppSpacing.spacing12),
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
              AppSpacing.spacing8_Box,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.firstName ?? locale.user_firstName_placeholder,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    user.lastName ?? locale.user_lastName_placeholder,
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
          return InkWell(
            onTap: () {
              // Navigate to quests tab
              DefaultTabController.of(context).animateTo(1);
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderMedium),
                borderRadius: AppRadius.small,
              ),
              padding: const EdgeInsets.all(AppSpacing.spacing24 * scale),
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
                  AppSpacing.spacing4_Box,
                  Flexible(
                    child: AutoSizeText(
                      (questGroup.group?.title ?? '').toString(),
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: math.max(16 * scale, 2),
                      ),
                      maxFontSize: math.max(16 * scale, 2),
                      minFontSize: math.max(10 * scale, 2),
                      maxLines: 2,
                    ),
                  ),
                  AppSpacing.spacing16_Box,
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
                        width: (constraints.maxWidth - 2 * AppSpacing.spacing24 * scale) *
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

class PossibleRewardsBox extends StatefulWidget {
  const PossibleRewardsBox({super.key});

  @override
  State<PossibleRewardsBox> createState() => _PossibleRewardsBoxState();
}

class _PossibleRewardsBoxState extends State<PossibleRewardsBox> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context);
    final demoRewards = <RewardItem>[
      const RewardItem(
        id: "reward_le_dietrich",
        title: "Le Dietrich",
        kind: RewardKind.cinema,
        city: "Poitiers",
        imageUrl:
            "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/15-movies-set-in-turkey_5cef7069-aa9a-4cd1-adc0-fcf4d19203bf.webp?alt=media&token=cb74c199-be90-40f6-b0ca-fae56cf55fd7",
        remainingPlaces: 5,
        costDiamonds: 200,
        address: RewardAddress(
          line1: "34 Boulevard Chasseigne",
          postalCode: "86000",
          city: "Poitiers",
          googleMapsUrl:
              "https://www.google.com/maps/search/?api=1&query=34%20Boulevard%20Chasseigne%2C%2086000%20Poitiers%2C%20France",
        ),
      ),
      const RewardItem(
        id: "reward_confort_moderne",
        title: "Le Confort Moderne",
        kind: RewardKind.concertHall,
        city: "Poitiers",
        imageUrl:
            "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/tap-poitiers.webp?alt=media&token=adeabe1c-2064-4642-9c82-25eb45f8388f",
        remainingPlaces: 5,
        costDiamonds: 350,
        address: RewardAddress(
          line1: "185 Rue du Faubourg du Pont-Neuf",
          postalCode: "86000",
          city: "Poitiers",
          googleMapsUrl:
              "https://www.google.com/maps/search/?api=1&query=185%20Rue%20du%20Faubourg%20du%20Pont-Neuf%2C%2086000%20Poitiers%2C%20France",
        ),
      ),
      const RewardItem(
        id: "reward_theatre_auditorium",
        title: "Théâtre Auditorium",
        kind: RewardKind.theatre,
        city: "Poitiers",
        imageUrl:
            "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/5a35cb1c459a45014e8b45b5.webp?alt=media&token=5c3fb9c4-9fb1-4a9c-8e7c-9a7786d195f5",
        remainingPlaces: 5,
        costDiamonds: 400,
        address: RewardAddress(
          line1: "6 Rue de la Marne",
          postalCode: "86000",
          city: "Poitiers",
          googleMapsUrl:
              "https://www.google.com/maps/search/?api=1&query=6%20Rue%20de%20la%20Marne%2C%2086000%20Poitiers%2C%20France",
        ),
      ),
      const RewardItem(
        id: "reward_pb86",
        title: "PB86",
        kind: RewardKind.sportsMatch,
        city: "Poitiers",
        imageUrl:
            "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/arena-futuroscope-poitiers-basket.jpg?alt=media&token=74c5e006-21d5-4407-9405-d88433da02b6",
        remainingPlaces: 5,
        costDiamonds: 250,
        address: RewardAddress(
          line1: "Arena Futuroscope, Avenue du Futuroscope",
          postalCode: "86360",
          city: "Chasseneuil-du-Poitou",
          googleMapsUrl:
              "https://www.google.com/maps/search/?api=1&query=Arena%20Futuroscope%2C%20Avenue%20du%20Futuroscope%2C%2086360%20Chasseneuil-du-Poitou%2C%20France",
        ),
      ),
      const RewardItem(
        id: "reward_futuroscope",
        title: "Futuroscope",
        kind: RewardKind.themePark,
        city: "Poitiers",
        imageUrl:
            "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/9485c939acd9496783a80d3473b0cad8.avif?alt=media&token=7295f9ba-0829-44c8-a07c-4bc74900d578",
        remainingPlaces: 5,
        costDiamonds: 500,
        address: RewardAddress(
          line1: "Avenue René Monory",
          postalCode: "86360",
          city: "Chasseneuil-du-Poitou",
          googleMapsUrl:
              "https://www.google.com/maps/search/?api=1&query=Avenue%20Ren%C3%A9%20Monory%2C%2086360%20Chasseneuil-du-Poitou%2C%20France",
        ),
      ),
    ];

    return Container(
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 500),
      decoration: BoxDecoration(
        // color: AppColors.primaryPressed,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
      padding: const EdgeInsets.only(
        top: AppSpacing.spacing24,
        right: AppSpacing.spacing24,
        left: AppSpacing.spacing24,
        bottom: AppSpacing.spacing12 + AppSpacing.spacing4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: AutoSizeText(
                  locale.parcoursRewards_possibleTitle,
                  style: GoogleFonts.anton(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    height: 44 / 28,
                    letterSpacing: -0.56,
                    color: AppButtonColors.secondaryTextDefault,
                  ),
                  maxFontSize: 28,
                  minFontSize: 14,
                  maxLines: 1,
                ),
              ),
              MouseRegion(
                onEnter: (event) {
                  _isHovering = true;
                  setState(() {});
                },
                onExit: (event) {
                  _isHovering = false;
                  setState(() {});
                },
                child: AppXButton(
                  text: locale.parcoursRewards_seeAll,
                  onPressed: () {
                    // Switch to rewards tab
                    DefaultTabController.of(context).animateTo(2);
                  },
                  fgColor: !_isHovering ? AppButtonColors.tertiaryTextDefault : AppButtonColors.tertiaryTextHover,
                  bgColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onPressedColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  isLoading: false,
                ),
              ),
            ],
          ),
          AppSpacing.spacing16_Box,
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: math.min(demoRewards.length, 3),
              // itemExtent: 100,
              itemBuilder: (context, index) {
                final reward = demoRewards[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == math.min(demoRewards.length, 3) - 1 ? 0 : AppSpacing.spacing16,
                  ),
                  child: RewardListItem(reward: reward),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RewardListItem extends StatefulWidget {
  final RewardItem reward;

  const RewardListItem({
    super.key,
    required this.reward,
  });

  @override
  State<RewardListItem> createState() => _RewardListItemState();
}

class _RewardListItemState extends State<RewardListItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    return LayoutBuilder(builder: (context, constraints) {
      return MouseRegion(
        cursor: MouseCursor.defer,
        onEnter: (event) {
          // _isHovering = true;
          setState(() {});
        },
        onExit: (event) {
          _isHovering = false;
          setState(() {});
        },
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              // color: Colors.yellow,
              color: AppColors.backgroundDefault,
              border: Border.all(color: _isHovering ? AppColors.primaryHover : AppColors.borderLight, width: 2),
              borderRadius: AppRadius.small,
              boxShadow: [
                BoxShadow(
                  color: _isHovering ? AppColors.primaryHover : AppColors.secondaryHover,
                  blurRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
              image: _isHovering
                  ? const DecorationImage(
                      image: AssetImage(AppImages.CFCardBackgroundPath),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      opacity: 1,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(AppSpacing.spacing12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.25,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: AppRadius.tinyTiny,
                    child: CachedNetworkImage(
                      imageUrl: widget.reward.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Container(color: AppColors.borderLight);
                      },
                      errorWidget: (context, url, error) {
                        return Container(
                          color: AppColors.borderLight,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                AppSpacing.spacing16_Box,
                Expanded(
                  flex: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.reward.title,
                        maxLines: 1,
                        maxFontSize: theme.textTheme.bodyLarge!.fontSize!,
                        minFontSize: theme.textTheme.bodySmall!.fontSize!,
                        style: GoogleFonts.inter(
                          color: _isHovering ? AppColors.textInverted : AppColors.textPrimary,
                          fontSize: isMobile
                              ? theme.textTheme.displayMedium!.fontSize
                              : theme.textTheme.headlineSmall!.fontSize,
                          fontWeight: FontWeight.w600,
                          // height: 1 / 3.8,
                        ),
                      ),
                      AppSpacing.spacing2_Box,
                      Text(
                        "${widget.reward.kind.label(locale)} • ${widget.reward.city}",
                        style: (isMobile ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)?.copyWith(
                          color: _isHovering ? AppColors.textInverted : AppColors.textSecondary,
                          // height: 1 / 2.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class RecentActivitiesBox extends StatelessWidget {
  const RecentActivitiesBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
    return Container(
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 500),
      decoration: BoxDecoration(
        color: AppColors.primaryDefault,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
    );
  }
}
