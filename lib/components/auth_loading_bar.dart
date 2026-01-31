import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/l10n/l10n.dart';

class AuthLoadingBar extends StatefulWidget {
  const AuthLoadingBar({super.key});

  @override
  State<AuthLoadingBar> createState() => _AuthLoadingBarState();
}

class _AuthLoadingBarState extends State<AuthLoadingBar> with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  Timer? _messageTimer;
  static const int _messageCount = 9;

  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Animation max 15 secondes
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..forward();

    // Message qui change toutes les 2 secondes
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messageCount;
      });
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _progressCtrl.dispose();
    super.dispose();
  }

  double _clampedProgress(double raw) {
    // 🔥 On évite que ça arrive à 100% trop vite si l’auth traîne.
    // La barre monte jusqu’à 95% max en 15s.
    return math.min(raw * 0.95, 0.95);
  }

  @override
  Widget build(BuildContext context) {
    final w = math.min(MediaQuery.of(context).size.width * 0.85, 520.0);
    final locale = AppLocalizations.of(context);
    final messages = [
      locale.authLoading_message_engineInit,
      locale.authLoading_message_uiArtifacts,
      locale.authLoading_message_permissionsCheck,
      locale.authLoading_message_modulesCompile,
      locale.authLoading_message_cacheSync,
      locale.authLoading_message_profileFetch,
      locale.authLoading_message_sessionPrep,
      locale.authLoading_message_renderOptimize,
      locale.authLoading_message_finalize,
    ];

    return Material(
      color: AppColors.backgroundColor,
      child: SizedBox(
        width: w,
        child: AnimatedBuilder(
          animation: _progressCtrl,
          builder: (context, _) {
            final raw = _progressCtrl.value; // 0.0 -> 1.0 en 15s
            final progress = _clampedProgress(raw); // 0.0 -> 0.95 max

            final int percent = (progress * 100).round().clamp(0, 99).toInt();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---- Titre "Loading..."
                Text(
                  locale.authLoading_title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // ---- La barre (style image)
                _LoadingBar(
                  height: 36,
                  progress: progress,
                  label: "$percent%",
                ),

                const SizedBox(height: 10),

                // ---- Messages artefacts
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) {
                    return FadeTransition(opacity: anim, child: child);
                  },
                  child: Text(
                    messages[_messageIndex % messages.length],
                    key: ValueKey(_messageIndex),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 6),

                // ---- Petite ligne “debug” (optionnel)
                Text(
                  locale.authLoading_debugLine(percent),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  final double height;
  final double progress; // 0..1
  final String label;

  const _LoadingBar({
    required this.height,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primaryHover,
        borderRadius: AppRadius.small,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            spreadRadius: 0,
            offset: Offset(0, 6),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final innerW = constraints.maxWidth;
          final fillW = innerW * progress;

          return Stack(
            children: [
              // Background interne
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryDefault.withAlpha(100),
                  borderRadius: AppRadius.tiny,
                ),
              ),

              // Fill blanc (progression)
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: fillW,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFocus,
                  borderRadius: AppRadius.tiny,
                ),
              ),

              // Label à droite dans la barre (comme sur l’image)
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: Padding(
              //     padding: const EdgeInsets.only(right: 32),
              //     child: Text(
              //       label,
              //       style: const TextStyle(
              //         fontSize: 14,
              //         fontWeight: FontWeight.w800,
              //         color: Colors.black,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}
