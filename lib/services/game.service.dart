import 'dart:convert';
import 'package:http/http.dart' as http;

class GameService {
  static const baseUrl = 'https://checkermateapi.onrender.com';

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
