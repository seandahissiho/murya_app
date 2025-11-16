import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/models/resource.dart';

part 'article_viewer.dart';
part 'podcast_viewer.dart';
part 'video_viewer.dart';

class ResourceViewerLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.userResourceViewerModule];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('resourceViewer-page-$languageCode'),
        title: 'ResourceViewer Page',
        child: ViewerHandler(),
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
        resource = Resource(
          id: resourceId ?? '1',
          type: ResourceType.article,
          title: 'Sample Resource',
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
        return const Center(child: Text('Unsupported resource type'));
    }
  }
}
