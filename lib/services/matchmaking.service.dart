import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchmakingService {
  static const baseUrl = 'https://checkermateapi.onrender.com';

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
