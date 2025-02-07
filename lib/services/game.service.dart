import 'dart:convert';
import 'package:http/http.dart' as http;

class GameService {
  static const baseUrl = 'https://checkermateapi.onrender.com';

  /// GET /game/:gameId
  /// Response example:
  /// {
  ///   "id": "game123",
  ///   "player1Id": "p1",
  ///   "player2Id": "p2",
  ///   "status": null | "Completed" | "Draw",
  ///   "winner": null | 1 | 2,
  ///   "moves": [
  ///     { "id":"m1", "from":"3,2", "to":"4,3", "playerId":"p1" },
  ///     ...
  ///   ],
  ///   "isMyTurn": true | false
  /// }
  static Future<Map<String, dynamic>?> getGame(
    int gameId,
    String playerId,
  ) async {
    final uri = Uri.parse('$baseUrl/games/$gameId');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': playerId,
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// POST /games/:gameId/forfeit
  /// Forfeits the current game
  static Future<bool> forfeitGame(int gameId, String playerId) async {
    final uri = Uri.parse('$baseUrl/games/$gameId/forfeit');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': playerId,
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// POST /games/:gameId/move?from=X,Y&to=X,Y
  /// Example: POST /games/123/move?from=2,3&to=3,4
  /// Return true if move was successful
  static Future<bool> postMove({
    required int gameId,
    required String playerId,
    required String from,
    required String to,
  }) async {
    final uri = Uri.parse('$baseUrl/games/$gameId/move?from=$from&to=$to');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': playerId,
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
