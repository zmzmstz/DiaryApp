import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../models/backlog_item.dart';

class BacklogRepository {
  // MongoDB Connection String
  // Getting connection string from .env file
  String get _mongoDbUri => dotenv.env['DB_URI'] ?? ""; 
  static const String _collectionName = "backlog_items";

  Db? _db;
  DbCollection? _collection;

  Future<void> _init() async {
    if (_db != null && _db!.isConnected) return;
    
    try {
      if (_mongoDbUri.isEmpty) {
        print("ERROR: DB_URI not found in .env file");
        return;
      }

      _db = await Db.create(_mongoDbUri);
      await _db!.open();
      _collection = _db!.collection(_collectionName);
      print("Connected to MongoDB!");
    } catch (e) {
      print("MongoDB Connection Error: $e");
    }
  }

  Future<List<BacklogItem>> getBacklogItems() async {
    try {
      await _init();
      if (_collection == null) return [];

      final List<Map<String, dynamic>> data = await _collection!.find().toList();
      print("Fetched ${data.length} items from MongoDB");
      
      return data.map((e) {
        // Mongo adds an '_id' field, but we use our own 'id'.
        // We just ignore '_id' when converting to BacklogItem as it's not in our model (or handled).
        // Ensure your model handles extra fields gracefully or just pass the map.
        return BacklogItem.fromJson(e);
      }).toList();
    } catch (e) {
      print("Error loading data from MongoDB: $e");
      return [];
    }
  }

  // Legacy method kept for compatibility, but we should use specific CRUD methods
  Future<void> saveBacklogItems(List<BacklogItem> items) async {
    // This method was used to overwrite the local file. 
    // In a database context, we shouldn't overwrite the whole collection.
    // However, if the Bloc relies on this, we might need to implement a bulk update or ignore it.
    // Ideally, the Bloc should call add/update/delete.
    print("Warning: saveBacklogItems called. Use add/update/delete for MongoDB efficiency.");
  }

  Future<void> addBacklogItem(BacklogItem item) async {
    await _init();
    if (_collection != null) {
      await _collection!.insert(item.toJson());
      print("Inserted item ${item.title} into MongoDB");
    }
  }

  Future<void> updateBacklogItem(BacklogItem item) async {
    await _init();
    if (_collection != null) {
      // Find by our custom 'id' field
      await _collection!.update(
        where.eq('id', item.id),
        item.toJson(),
      );
      print("Updated item ${item.title} in MongoDB");
    }
  }

  Future<void> deleteBacklogItem(String id) async {
    await _init();
    if (_collection != null) {
      await _collection!.remove(where.eq('id', id));
      print("Deleted item $id from MongoDB");
    }
  }
}
