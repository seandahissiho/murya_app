import 'package:flutter/material.dart';
import 'package:murya/config/DS.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppSkeletonizer extends StatefulWidget {
  final bool enabled;
  final Widget child;

  const AppSkeletonizer({super.key, required this.enabled, required this.child});

  @override
  State<AppSkeletonizer> createState() => _AppSkeletonizerState();
}

class _AppSkeletonizerState extends State<AppSkeletonizer> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enableSwitchAnimation: true,
      enabled: widget.enabled,
      ignorePointers: false,
      ignoreContainers: false,
      containersColor: AppColors.secondaryPressed,
      effect: const ShimmerEffect(
        baseColor: AppColors.secondaryPressed,
        highlightColor: AppColors.secondaryFocus,
      ),
      child: widget.child,
    );
  }
}
