import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../services/player.service.dart';
import '../providers/player.provider.dart';
import 'home.screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? error;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? playerId = prefs.getString('playerId');

      if (playerId == null) {
        final newId = await PlayerService.register();
        if (newId == null) {
          setState(() {
            error = 'Registration failed. Please try again.';
          });
          return;
        }
        playerId = newId;
        await prefs.setString('playerId', playerId);
      }

      final playerModel = await PlayerService.getProfile(playerId);
      if (playerModel == null) {
        setState(() {
          error = 'Failed to fetch profile. Please try again.';
        });
        return;
      }

      if (!mounted) return;
      context.read<PlayerProvider>().setPlayer(playerModel);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        error = 'Unexpected error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
