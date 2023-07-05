/// Environment variables and shared app constants.
class Constants {
  static const SUPABASE_API_KEY = String.fromEnvironment('SUPABASE_ANNON_KEY');
  static const SUPABASE_URL = String.fromEnvironment('SUPABASE_URL');

  static List<String> getSupaBaseCredentials() {
    //final supabaseUrl = dotenv.env['SUPABASE_URL'];
    //final supabaseAnnonKey = dotenv.env['SUPABASE_ANNON_KEY'];
    //  if (supabaseUrl == null || supabaseAnnonKey == null) {
    //    throw Exception(
    //        'Please define SUPABASE_URL and SUPABASE_ANNON_KEY in your .env file');
    //  }
    print('SUPABASE_URL: $SUPABASE_URL');
    print('SUPABASE_API_KEY: $SUPABASE_API_KEY');
    return [SUPABASE_URL, SUPABASE_API_KEY];
  }
}
