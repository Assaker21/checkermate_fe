import 'package:flutter/material.dart';
import 'dart:async';

import 'checkers-board.screen.dart';
import '../services/matchmaking.service.dart';
import 'package:provider/provider.dart';
import '../providers/player.provider.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  bool _isLoading = true;
  String _statusMessage = '';
  Timer? _pollTimer;

  late String playerId;

  @override
  void initState() {
    super.initState();

    final player = context.read<PlayerProvider>().player;
    playerId = player?.id ?? '';

    _initMatchmaking();
  }

  @override
  void dispose() {
    if (playerId.isNotEmpty) {
      MatchmakingService.deleteMatchmake(playerId);
    }
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _initMatchmaking() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking matchmaking status...';
    });

    final getResponse = await MatchmakingService.getMatchmake(playerId);
    if (getResponse == null) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Failed to contact server.';
      });
      return;
    }

    if (getResponse['gameId'] != null) {
      _goToGameScreen(getResponse['gameId']);
      return;
    }

    final message = getResponse['message'];
    if (message == 'Waiting') {
      setState(() {
        _isLoading = false;
        _statusMessage = 'In queue, waiting for match...';
      });
      _startPolling();
    } else if (message == 'Not in queue') {
      await _handlePostMatchmake();
    } else {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Unexpected response: $message';
      });
    }
  }

  Future<void> _handlePostMatchmake() async {
    setState(() {
      _statusMessage = 'Joining queue...';
      _isLoading = true;
    });

    final postResponse = await MatchmakingService.postMatchmake(playerId);
    setState(() {
      _isLoading = false;
    });

    if (postResponse == null) {
      setState(() {
        _statusMessage = 'Failed to contact server when joining queue.';
      });
      return;
    }

    final message = postResponse['message'];

    if (message == 'Running') {
      final checkGame = await MatchmakingService.getMatchmake(playerId);
      if (checkGame != null && checkGame['gameId'] != null) {
        _goToGameScreen(checkGame['gameId']);
      } else {
        setState(() {
          _statusMessage = 'Could not retrieve gameId.';
        });
      }
    } else if (message == 'Added to queue') {
      setState(() {
        _statusMessage = 'Successfully joined queue. Waiting for match...';
      });
      _startPolling();
    } else if (message == 'Already in queue') {
      setState(() {
        _statusMessage = 'Already in queue. Waiting for match...';
      });
      _startPolling();
    } else {
      setState(() {
        _statusMessage = 'Unexpected response: $message';
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final resp = await MatchmakingService.getMatchmake(playerId);
      if (resp == null) return;

      if (resp['gameId'] != null) {
        _pollTimer?.cancel();
        _goToGameScreen(resp['gameId']);
      } else if (resp['message'] == 'Waiting') {
        setState(() {
          _statusMessage = 'Still waiting for a match...';
        });
      } else {
        setState(() {
          _statusMessage = 'No longer in queue. Unexpected?';
        });
        _pollTimer?.cancel();
      }
    });
  }

  void _goToGameScreen(int gameId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CheckersBoardScreen(gameId: gameId, opponentId: 'Game ID: $gameId'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cancelButton = ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text('Cancel'),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Matchmaking'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(_statusMessage),
                  const SizedBox(height: 16),
                  cancelButton,
                ],
              ),
      ),
    );
  }
}
