import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'widgets/home_shell.dart';

class KnuttApp extends StatelessWidget {
  const KnuttApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knutt vs. Herzmuschel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008B8B)),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de', 'DE'), Locale('en', 'US')],
      locale: const Locale('de', 'DE'),
      home: const HomeShell(),
    );
  }
}
