part of 'viewer_handler.dart';

class ArticleViewer extends StatefulWidget {
  final Resource resource;
  const ArticleViewer({super.key, required this.resource});

  @override
  State<ArticleViewer> createState() => _ArticleViewerState();
}

class _ArticleViewerState extends State<ArticleViewer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
