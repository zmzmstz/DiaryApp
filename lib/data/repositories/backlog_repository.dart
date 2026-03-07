import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/app_user.dart';
import '../../models/backlog_item.dart';

class BacklogRepository {
  static const String _pcIp = '192.168.1.105';
  static const String _baseUrl = 'http://$_pcIp:5038/api';

  String? _currentUsername;

  void setCurrentUser(String username) {
    _currentUsername = username;
  }

  // ─── Backlog CRUD ──────────────────────────────────

  Future<List<BacklogItem>> getBacklogItems() async {
    try {
      if (_currentUsername == null) return [];
      final response = await http.get(
        Uri.parse('$_baseUrl/backlog/$_currentUsername'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => BacklogItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print("Error loading backlog: $e");
      return [];
    }
  }

  Future<void> saveBacklogItems(List<BacklogItem> items) async {}

  Future<void> addBacklogItem(BacklogItem item) async {
    final body = item.toJson();
    body['owner'] = _currentUsername;
    await http.post(
      Uri.parse('$_baseUrl/backlog'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<void> updateBacklogItem(BacklogItem item) async {
    final body = item.toJson();
    body['owner'] = _currentUsername;
    await http.put(
      Uri.parse('$_baseUrl/backlog/${item.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<void> deleteBacklogItem(String id) async {
    await http.delete(Uri.parse('$_baseUrl/backlog/$id'));
  }

  // ─── Auth ──────────────────────────────────────────

  Future<AppUser?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = AppUser(
          username: data['username'] as String,
          displayName: data['displayName'] as String,
        );
        _currentUsername = user.username;
        return user;
      }
      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  Future<AppUser> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'displayName': displayName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = AppUser(
        username: data['username'] as String,
        displayName: data['displayName'] as String,
      );
      _currentUsername = user.username;
      return user;
    }

    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Registration failed');
  }
}
