import 'dart:collection';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/resources/resources_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/fil_arianne.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/screens/base.dart';
import 'package:murya/screens/ressources/resources.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt_flutter;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt_iframe;

part 'article_viewer.dart';
part 'podcast_viewer.dart';
part 'video_viewer.dart';

String _formatDurationFromSeconds(AppLocalizations locale, int totalSeconds) {
  final int safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
  final int hours = safeSeconds ~/ 3600;
  final int minutes = (safeSeconds % 3600) ~/ 60;
  final int seconds = safeSeconds % 60;

  final List<String> parts = [];
  if (hours > 0) {
    parts.add(locale.duration_hours(hours));
  }
  if (minutes > 0) {
    parts.add(locale.duration_minutes(minutes));
  }
  if (seconds > 0 || parts.isEmpty) {
    parts.add(locale.duration_seconds(seconds));
  }
  return parts.join(' ');
}

class ResourceViewerLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.userResourceViewerModule];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    // Cast the state to BeamState (or your custom state class)
    // final state = Beamer.of(context).currentBeamLocation.state as BeamState;
    // Now you can access the 'data' property
    Map<String, dynamic>? data = this.data as Map<String, dynamic>?;
    final Resource? resource = data != null && data['data'] is Resource ? data['data'] as Resource : null;

    return [
      BeamPage(
        key: ValueKey('resourceViewer-page-${context.read<AppBloc>().appLanguage.code}'),
        title: AppLocalizations.of(context).resourceViewerPageTitle,
        child: ViewerHandler(resource: resource),
      ),
    ];
  }
}

class ViewerHandler extends StatefulWidget {
  final Resource? resource;

  const ViewerHandler({
    super.key,
    this.resource,
  });

  @override
  State<ViewerHandler> createState() => _ViewerHandlerState();
}

class _ViewerHandlerState extends State<ViewerHandler> {
  Resource? resource;
  String? resourceId;
  bool _openSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      resourceId = beamState.pathParameters['id'];
      if (widget.resource != null) {
        setState(() {
          resource = widget.resource;
        });
        _sendOpenIfNeeded();
      } else if (resourceId != null && resourceId!.isNotEmpty) {
        context.read<ResourcesBloc>().add(LoadResourceDetails(resourceId: resourceId!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResourcesBloc, ResourcesState>(
      listener: (context, state) {
        if (state is ResourceDetailsLoaded) {
          setState(() {
            resource = state.resource;
          });
          _sendOpenIfNeeded();
        }
      },
      child: Builder(
        builder: (context) {
          if (resource == null) {
            return const Center(child: CircularProgressIndicator());
          }
          switch (resource?.type) {
            case ResourceType.article:
              return ArticleViewer(resource: resource!);
            case ResourceType.video:
              return VideoViewer(resource: resource!);
            case ResourceType.podcast:
              return PodcastViewer(resource: resource!);
            // ignore: unreachable_switch_default
            default:
              return Center(
                child: Text(AppLocalizations.of(context).unsupportedResourceType),
              );
          }
        },
      ),
    );
  }

  void _sendOpenIfNeeded() {
    if (_openSent) return;
    final res = resource;
    if (res == null || res.id == null || res.id!.isEmpty) return;
    _openSent = true;
    context.read<ResourcesBloc>().add(OpenResource(resourceId: res.id!));
  }
}
