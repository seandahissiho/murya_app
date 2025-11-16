part of 'viewer_handler.dart';

class VideoViewer extends StatefulWidget {
  final Resource resource;
  const VideoViewer({super.key, required this.resource});

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
