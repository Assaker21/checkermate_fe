// lib/models/player_model.dart

class PlayerModel {
  final String id;
  final PlayerStats stats;

  PlayerModel({
    required this.id,
    required this.stats,
  });

  // A factory constructor to parse from JSON.
  // Adjust field names to match your backend's response structure.
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      stats: PlayerStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }
}

class PlayerStats {
  final int played;
  final int win;
  final int draw;
  final int loss;
  final int winStreak;
  final int lossStreak;
  final int drawStreak;

  PlayerStats({
    required this.played,
    required this.win,
    required this.draw,
    required this.loss,
    required this.winStreak,
    required this.lossStreak,
    required this.drawStreak,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      played: json['played'] as int,
      win: json['win'] as int,
      draw: json['draw'] as int,
      loss: json['loss'] as int,
      winStreak: json['winStreak'] as int,
      lossStreak: json['lossStreak'] as int,
      drawStreak: json['drawStreak'] as int,
    );
  }
}
