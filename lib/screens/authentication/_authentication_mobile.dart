part of 'authentication.dart';

class MobileAuthenticationScreen extends StatelessWidget {
  final AuthenticationTab initialTab;

  const MobileAuthenticationScreen({super.key, required this.initialTab});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _tabIndex(initialTab),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: const [],
        ),
      ),
    );
  }
}

class MobileForgotPasswordScreen extends StatelessWidget {
  const MobileForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Forgot Password Screen'),
    );
  }
}
