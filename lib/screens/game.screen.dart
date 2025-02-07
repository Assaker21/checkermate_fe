import 'package:flutter/material.dart';
import 'matchmaking.screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example: We show current score and current win streak
    final int currentWinStreak = 3;
    final String score = "667"; // example

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Checkers Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Current Score: $score', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Current Win Streak: $currentWinStreak'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to matchmaking screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchmakingScreen(),
                  ),
                );
              },
              child: const Text('Play'),
            ),
          ],
        ),
      ),
    );
  }
}
