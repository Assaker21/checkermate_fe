import 'package:flutter/material.dart';
import '../models/player.model.dart';

class PlayerProvider with ChangeNotifier {
  PlayerModel? _player;

  PlayerModel? get player => _player;

  bool get isLoggedIn => _player != null;

  void setPlayer(PlayerModel player) {
    _player = player;
    notifyListeners();
  }

  void clearPlayer() {
    _player = null;
    notifyListeners();
  }
}
