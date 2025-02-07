import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/checkers-board.widget.dart';
import '../services/game.service.dart';
import '../providers/player.provider.dart';

class CheckersBoardScreen extends StatefulWidget {
  final int gameId;
  final String opponentId;

  const CheckersBoardScreen({
    super.key,
    required this.gameId,
    required this.opponentId,
  });

  @override
  State<CheckersBoardScreen> createState() => _CheckersBoardScreenState();
}

class _CheckersBoardScreenState extends State<CheckersBoardScreen> {
  bool _loading = true;
  String? _error;
  Timer? _pollTimer;

  String? _player1Id;
  String? _player2Id;
  String? _status;
  int? _winner;
  bool _isMyTurn = false;
  List<Map<String, dynamic>> _moves = [];

  String _myColor = 'R';

  @override
  void initState() {
    super.initState();
    _pollGame();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) => _pollGame());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _pollGame() async {
    final playerId = context.read<PlayerProvider>().player?.id ?? '';
    if (playerId.isEmpty) {
      setState(() {
        _error = 'No playerId found in provider.';
        _loading = false;
      });
      return;
    }

    final data = await GameService.getGame(widget.gameId, playerId);
    if (data == null) {
      setState(() {
        _error = 'Failed to fetch game data.';
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = false;
      _player1Id = data['player1Id'] as String?;
      _player2Id = data['player2Id'] as String?;
      _status = data['status'] as String?;
      _winner = data['winner'] as int?;
      _isMyTurn = data['isMyTurn'] as bool? ?? false;
      final movesList = data['moves'] as List<dynamic>? ?? [];
      _moves = movesList.map((m) => m as Map<String, dynamic>).toList();

      if (playerId == _player1Id) {
        _myColor = 'R';
      } else {
        _myColor = 'B';
      }
    });
  }

  Future<void> _onForfeit() async {
    final playerId = context.read<PlayerProvider>().player?.id ?? '';
    if (playerId.isEmpty) return;
    final success = await GameService.forfeitGame(widget.gameId, playerId);
    if (success) {
      _goHome();
    } else {
      setState(() => _error = 'Failed to forfeit game.');
    }
  }

  Future<void> _onMove(String moveDesc) async {
    if (!_isMyTurn) {
      setState(() => _error = 'Not your turn.');
      return;
    }

    final playerId = context.read<PlayerProvider>().player?.id ?? '';
    if (playerId.isEmpty) return;

    try {
      final parts = moveDesc.split('|');
      final fromStr = parts[0].replaceAll(RegExp(r'[^0-9,]'), '');
      final toStr = parts[1].replaceAll(RegExp(r'[^0-9,]'), '');

      final success = await GameService.postMove(
        gameId: widget.gameId,
        playerId: playerId,
        from: fromStr,
        to: toStr,
      );
      if (!success) {
        setState(
            () => _error = 'Server move refused. Will revert on next poll.');
      } else {
        _pollGame();
      }
    } catch (e) {
      setState(() => _error = 'Invalid move format: $e');
    }
  }

  void _goHome() {
    _pollTimer?.cancel();

    _player1Id = null;
    _player2Id = null;
    _status = null;
    _winner = null;
    _moves = [];

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_status == 'Completed') {
      String winnerStr = 'Unknown winner';
      if (_winner == 1) {
        winnerStr = 'Player1 ($_player1Id) won';
      } else if (_winner == 2) {
        winnerStr = 'Player2 ($_player2Id) won';
      }
      return _buildEndScreen('Game Completed', winnerStr);
    } else if (_status == 'Draw') {
      return _buildEndScreen('Game Draw', 'Nobody wins.');
    }

    final opponentId = context.read<PlayerProvider>().player?.id == _player1Id
        ? _player2Id
        : _player1Id;

    return Scaffold(
      appBar: AppBar(title: Text('Playing against $opponentId')),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Text(_isMyTurn ? 'Your turn!' : 'Waiting on opponent...'),
          Expanded(
            child: CheckersBoard(
              color: _myColor,
              canMove: _isMyTurn,
              moves: _moves,
              onMove: _onMove,
            ),
          ),
          ElevatedButton(
            onPressed: _onForfeit,
            child: const Text('Forfeit'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEndScreen(String title, String msg) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(msg),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _goHome,
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
