import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/checkers-board.widget.dart'; // Child widget below
import '../services/game.service.dart'; // Hypothetical service
import '../providers/player.provider.dart'; // For playerId

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

  // Data from server
  String? _player1Id;
  String? _player2Id;
  String? _status; // null | "Completed" | "Draw"
  int? _winner; // null | 1 | 2
  bool _isMyTurn = false;
  List<Map<String, dynamic>> _moves = [];

  // My color locally
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

      // Determine my color
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
      _goHome(); // End the game flow
    } else {
      setState(() => _error = 'Failed to forfeit game.');
    }
  }

  /// Called when local user attempts a move
  /// If the server disagrees, next poll will fix our board state
  Future<void> _onMove(String moveDesc) async {
    if (!_isMyTurn) {
      setState(() => _error = 'Not your turn.');
      return;
    }

    final playerId = context.read<PlayerProvider>().player?.id ?? '';
    if (playerId.isEmpty) return;

    // Example: "from=(2,3)|to=(3,4)"
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
        // Force immediate poll if success
        _pollGame();
      }
    } catch (e) {
      setState(() => _error = 'Invalid move format: $e');
    }
  }

  /// If game ends or user clicks "Go Home," we want to reset everything.
  /// Then we pop back to a screen that eventually leads to matchmaking next time they click "Play."
  void _goHome() {
    // 1) Cancel polling
    _pollTimer?.cancel();

    // 2) Possibly reset some global state if needed
    // context.read<SomeGlobalGameState>().reset();
    _player1Id = null;
    _player2Id = null;
    _status = null;
    _winner = null;
    _moves = [];

    // 3) Pop back to the home screen or root
    //    so next time they click "Play," they see the matchmaking screen
    Navigator.of(context).popUntil((route) => route.isFirst);
    // Or you could do pushAndRemoveUntil if your home is not the first route
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Check if game ended
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

    // Otherwise ongoing
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
              color: _myColor, // 'R' or 'B'
              canMove: _isMyTurn,
              moves: _moves, // from server
              onMove: _onMove, // local => server call
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
