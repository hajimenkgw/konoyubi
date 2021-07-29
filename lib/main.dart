import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'ui/onboarding/onboarding_screen.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://8ca720ad4ee548de839aebe3214c65da@o933562.ingest.sentry.io/5882678';
    },
    appRunner: () => runApp(App()),
  );

  // or define SENTRY_DSN via Dart environment variable (--dart-define)
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'konoyubi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
