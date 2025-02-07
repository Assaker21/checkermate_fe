// lib/services/player_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.model.dart';

class PlayerService {
  static const baseUrl = 'https://checkermateapi.onrender.com';

  /// Calls GET /register to obtain a new player ID
  static Future<String?> register() async {
    try {
      final uri = Uri.parse('$baseUrl/register');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Calls GET /profile with Authorization header, returns a PlayerModel
  static Future<PlayerModel?> getProfile(String playerId) async {
    try {
      final uri = Uri.parse('$baseUrl/profile');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': playerId,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PlayerModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
