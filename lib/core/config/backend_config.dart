import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackendConfig {
  static const String _defaultBaseUrl = 'http://127.0.0.1:5038';

  static String get apiBaseUrl {
    final raw = (dotenv.env['API_BASE_URL'] ?? '').trim();
    final base = raw.isEmpty ? _defaultBaseUrl : raw;
    final normalizedBase = base.replaceAll(RegExp(r'/+$'), '');

    if (normalizedBase.endsWith('/api')) {
      return normalizedBase;
    }

    return '$normalizedBase/api';
  }
}
