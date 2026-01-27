import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/resources/resources_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/fil_arianne.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/screens/base.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

part 'article_viewer.dart';
part 'podcast_viewer.dart';
part 'video_viewer.dart';

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
}
