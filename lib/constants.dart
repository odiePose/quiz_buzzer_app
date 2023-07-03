import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment variables and shared app constants.
abstract class Constants {
  static List<String> getSupaBaseCredentials() {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnnonKey = dotenv.env['SUPABASE_ANNON_KEY'];
    if (supabaseUrl == null || supabaseAnnonKey == null) {
      throw Exception(
          'Please define SUPABASE_URL and SUPABASE_ANNON_KEY in your .env file');
    }
    return [supabaseUrl, supabaseAnnonKey];
  }
}
