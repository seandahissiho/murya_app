import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/screens/base.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

part 'article_viewer.dart';
part 'podcast_viewer.dart';
part 'video_viewer.dart';

class ResourceViewerLocation
    extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.userResourceViewerModule];

  @override
  List<BeamPage> buildPages(
      BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    // Cast the state to BeamState (or your custom state class)
    // final state = Beamer.of(context).currentBeamLocation.state as BeamState;
    // Now you can access the 'data' property
    Map<String, dynamic>? data = this.data as Map<String, dynamic>?;
    final Resource? resource = data != null && data['data'] is Resource
        ? data['data'] as Resource
        : null;

    return [
      BeamPage(
        key: ValueKey('resourceViewer-page-$languageCode'),
        title: AppLocalizations.of(context)!.resourceViewerPageTitle,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      final resourceId = beamState.pathParameters['id'];

      // For demonstration, we'll just create a dummy resource.
      setState(() {
        resource = widget.resource ??
            Resource(
              id: resourceId ?? '1',
              type: ResourceType.article,
              title: AppLocalizations.of(context)!.sampleResource,
            );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
            child: Text(AppLocalizations.of(context)!.unsupportedResourceType));
    }
  }
}
