import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/splash/splash_screen.dart';
import 'utils/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'AR Study Cards',
            theme: ThemeData(
              primarySwatch: Colors.teal,
              brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}