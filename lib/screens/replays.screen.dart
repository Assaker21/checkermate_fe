import 'package:flutter/material.dart';
import '../models/replay.model.dart';
import '../widgets/replay-item.widget.dart';

class ReplaysScreen extends StatelessWidget {
  const ReplaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ReplayModel> replays = [
      ReplayModel(
          date: DateTime.now().subtract(const Duration(days: 1)),
          opponent: 'Alice'),
      ReplayModel(
          date: DateTime.now().subtract(const Duration(days: 2)),
          opponent: 'Bob'),
      ReplayModel(
          date: DateTime.now().subtract(const Duration(days: 3)),
          opponent: 'Charlie'),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Replays'),
      ),
      body: ListView.builder(
        itemCount: replays.length,
        itemBuilder: (context, index) {
          return ReplayItem(replay: replays[index]);
        },
      ),
    );
  }
}
