import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/onboarding/splash_screen.dart';

import 'utils/providers/providers.dart';

void main() {
  runApp(
    MultiProvider(
      providers: getProviders(''), // Initial empty token
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
