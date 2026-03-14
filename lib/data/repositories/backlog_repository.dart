import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/app_user.dart';
import '../../models/backlog_item.dart';
import '../../core/config/backend_config.dart';

class BacklogRepository {
  String get _baseUrl => BackendConfig.apiBaseUrl;

  String? _currentUsername;
  String? _accessToken;

  void setCurrentUser(String username) {
    _currentUsername = username;
  }

  void clearSession() {
    _currentUsername = null;
    _accessToken = null;
  }

  Map<String, String> get _authHeaders {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      return {'Content-Type': 'application/json'};
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── Backlog CRUD ──────────────────────────────────

  Future<List<BacklogItem>> getBacklogItems() async {
    try {
      if (_accessToken == null) return [];
      final response = await http.get(Uri.parse('$_baseUrl/backlog'), headers: _authHeaders);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => BacklogItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (response.statusCode == 401) {
        clearSession();
        return [];
      }

      return [];
    } catch (e) {
      print("Error loading backlog: $e");
      return [];
    }
  }

  Future<void> saveBacklogItems(List<BacklogItem> items) async {}

  Future<void> addBacklogItem(BacklogItem item) async {
    if (_accessToken == null) throw Exception('Not authenticated');

    final body = item.toJson();
    body['owner'] = _currentUsername;
    final response = await http.post(
      Uri.parse('$_baseUrl/backlog'),
      headers: _authHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add backlog item');
    }
  }

  Future<void> updateBacklogItem(BacklogItem item) async {
    if (_accessToken == null) throw Exception('Not authenticated');

    final body = item.toJson();
    body['owner'] = _currentUsername;
    final response = await http.put(
      Uri.parse('$_baseUrl/backlog/${item.id}'),
      headers: _authHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update backlog item');
    }
  }

  Future<void> deleteBacklogItem(String id) async {
    if (_accessToken == null) throw Exception('Not authenticated');

    final response = await http.delete(
      Uri.parse('$_baseUrl/backlog/$id'),
      headers: _authHeaders,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete backlog item');
    }
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
        final userData = data['user'] as Map<String, dynamic>;
        final user = AppUser(
          username: userData['username'] as String,
          displayName: userData['displayName'] as String,
        );
        _accessToken = data['accessToken'] as String?;
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

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final userData = data['user'] as Map<String, dynamic>;
      final user = AppUser(
        username: userData['username'] as String,
        displayName: userData['displayName'] as String,
      );
      _accessToken = data['accessToken'] as String?;
      _currentUsername = user.username;
      return user;
    }

    final error = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(error['error'] ?? 'Registration failed');
  }

  String? get accessToken => _accessToken;
}
