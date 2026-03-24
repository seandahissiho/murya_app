import 'package:flutter/material.dart';
import 'package:murya/analytics/analytics_service.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class AnalyticsReplay extends StatelessWidget {
  final Widget child;

  const AnalyticsReplay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AnalyticsService.instance.isReplayEnabled) {
      return child;
    }

    return PostHogWidget(child: child);
  }
}

class AnalyticsSensitive extends StatelessWidget {
  final Widget child;

  const AnalyticsSensitive({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AnalyticsService.instance.isReplayEnabled) {
      return child;
    }

    return PostHogMaskWidget(child: child);
  }
}
