import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../models/app_user.dart';

class UserRepository {
  String get _mongoDbUri => dotenv.env['DB_URI'] ?? '';
  static const String _collectionName = 'users';

  Db? _db;
  DbCollection? _collection;

  Future<void> _init() async {
    if (_db != null && _db!.isConnected) return;
    if (_mongoDbUri.isEmpty) return;

    try {
      _db = await Db.create(_mongoDbUri);
      await _db!.open();
      _collection = _db!.collection(_collectionName);
    } catch (e) {
      print('UserRepository connection error: $e');
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<AppUser?> login(String username, String password) async {
    await _init();
    if (_collection == null) return null;

    final doc = await _collection!.findOne(
      where.eq('username', username.toLowerCase().trim()),
    );

    if (doc == null) return null;

    final storedHash = doc['passwordHash'] as String;
    if (storedHash != _hashPassword(password)) return null;

    return AppUser.fromJson(doc);
  }

  Future<AppUser?> register(
      String username, String displayName, String password) async {
    await _init();
    if (_collection == null) return null;

    final normalizedUsername = username.toLowerCase().trim();

    final existing = await _collection!.findOne(
      where.eq('username', normalizedUsername),
    );
    if (existing != null) return null;

    final user = AppUser(
      id: ObjectId().oid,
      username: normalizedUsername,
      displayName: displayName.trim(),
      createdAt: DateTime.now(),
    );

    final doc = user.toJson();
    doc['passwordHash'] = _hashPassword(password);

    await _collection!.insert(doc);
    return user;
  }
}
