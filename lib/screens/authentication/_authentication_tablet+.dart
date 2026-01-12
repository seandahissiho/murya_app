part of 'authentication.dart';

class TabletAuthenticationScreen extends StatelessWidget {
  final AuthenticationTab initialTab;

  const TabletAuthenticationScreen({super.key, required this.initialTab});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _tabIndex(initialTab),
      child: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [],
        ),
      ),
    );
  }
}

class TabletForgotPasswordScreen extends StatelessWidget {
  const TabletForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Forgot Password Screen'),
    );
  }
}
