part of 'competencies_family_details.dart';

class MobileCfDetailsScreen extends StatefulWidget {
  const MobileCfDetailsScreen({super.key});

  @override
  State<MobileCfDetailsScreen> createState() => _MobileCfDetailsScreenState();
}

class _MobileCfDetailsScreenState extends State<MobileCfDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      final jobId = beamState.pathParameters['jobId'];
      final cfId = beamState.pathParameters['cfId'];
      context.read<JobBloc>().add(LoadCFDetails(context: context, jobId: jobId, cfId: cfId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
