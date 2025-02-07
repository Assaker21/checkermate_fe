import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player.provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final player = playerProvider.player;

    if (player == null) {
      return const Center(child: Text('No player data'));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatRow('Games Played', player.stats.played.toString()),
            _buildStatRow('Games Won', player.stats.win.toString()),
            _buildStatRow('Games Drawn', player.stats.draw.toString()),
            _buildStatRow('Games Lost', player.stats.loss.toString()),
            _buildStatRow(
                'Longest Win Streak', player.stats.winStreak.toString()),
            _buildStatRow(
                'Longest Draw Streak', player.stats.drawStreak.toString()),
            _buildStatRow(
                'Longest Loss Streak', player.stats.lossStreak.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }
}
