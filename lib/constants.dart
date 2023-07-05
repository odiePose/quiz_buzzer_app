/// Environment variables and shared app constants.
class Constants {
  // ignore: constant_identifier_names
  static const SUPABASE_API_KEY = String.fromEnvironment('SUPABASE_ANNON_KEY');
  // ignore: constant_identifier_names
  static const SUPABASE_URL = String.fromEnvironment('SUPABASE_URL');

  static List<String> getSupaBaseCredentials() {
    if (SUPABASE_URL == "" || SUPABASE_API_KEY == "") {
      throw Exception(
          'Please define SUPABASE_URL and SUPABASE_ANNON_KEY in your .env file');
    }
    return [SUPABASE_URL, SUPABASE_API_KEY];
  }
}
