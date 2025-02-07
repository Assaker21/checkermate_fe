import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchmakingService {
  static const baseUrl = 'https://checkermateapi.onrender.com';

  /// GET /matchmake
  ///   - { "gameId": 123 }       (already in game, integer gameId)
  ///   - { "message": "Waiting" }   (in queue)
  ///   - { "message": "Not in queue" }
  static Future<Map<String, dynamic>?> getMatchmake(String playerId) async {
    try {
      final uri = Uri.parse('$baseUrl/matchmake');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': playerId,
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('gameId')) {
          data['gameId'] = data['gameId'] as int;
        }
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// POST /matchmake
  ///   - { "message": "Running" }        (already in game)
  ///   - { "message": "Added to queue" } (queue join success)
  ///   - { "message": "Already in queue"}
  ///   - In some cases, server might also return { "gameId": 123 } (if in a game)
  static Future<Map<String, dynamic>?> postMatchmake(String playerId) async {
    try {
      final uri = Uri.parse('$baseUrl/matchmake');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': playerId,
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('gameId')) {
          data['gameId'] = data['gameId'] as int;
        }
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// DELETE /matchmake
  /// Removes user from matchmaking queue if they're in it
  /// Returns true if success, false if error
  static Future<bool> deleteMatchmake(String playerId) async {
    try {
      final uri = Uri.parse('$baseUrl/matchmake');
      final response = await http.delete(
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
