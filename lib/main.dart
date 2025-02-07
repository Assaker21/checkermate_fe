import 'package:flutter/material.dart';
import 'screens/splash.screen.dart';
import 'package:provider/provider.dart';
import 'providers/player.provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => PlayerProvider(),
        child: MaterialApp(
          title: 'Flutter Checkers',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const SplashScreen(),
        ));
  }
}
