import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  bool _isGoogleInitialized = false;

  // Mengambil data user yang sedang login saat ini (jika ada)
  User? get currentUser => _client.auth.currentUser;

  // Mengecek apakah user sudah login
  bool get isAuthenticated => currentUser != null;

  // Fungsi Login menggunakan Google Sign-In
  Future<AuthResponse> signInWithGoogle() async {
    const webClientId = '136672805350-a9vmbfr3d4so5l41kho7ji21ailfehqg.apps.googleusercontent.com';

    // 1. Inisialisasi instance (Standar v7+)
    if (!_isGoogleInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: webClientId,
      );
      _isGoogleInitialized = true;
    }
    
    // 2. Memicu jendela login Google
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();


    // 3. Ambil idToken (accessToken diabaikan karena tidak otomatis tersedia di v7)
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'Gagal mendapatkan token kredensial dari Google.';
    }

    // 4. Teruskan token otentikasi ke Supabase (hanya idToken yang dikirim)
    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}