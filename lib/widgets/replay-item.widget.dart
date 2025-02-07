import 'package:flutter/material.dart';
import '../models/replay.model.dart';
import '../utils/date-format.util.dart';

class ReplayItem extends StatelessWidget {
  final ReplayModel replay;

  const ReplayItem({super.key, required this.replay});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Opponent: ${replay.opponent}'),
      subtitle: Text('Date: ${DateFormatUtils.formatDate(replay.date)}'),
      onTap: () {},
    );
  }
}
