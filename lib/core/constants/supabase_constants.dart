import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  // Mengambil Project URL secara aman dari file .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  // Mengambil anon/public key secara aman dari file .env
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}