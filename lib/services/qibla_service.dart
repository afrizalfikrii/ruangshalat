import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service untuk mengambil arah kiblat dari Aladhan API
/// Endpoint: GET https://api.aladhan.com/v1/qibla/{lat}/{lng}
class QiblaService {
  static const String _base = 'https://api.aladhan.com/v1';

  /// Mengembalikan sudut arah kiblat dalam derajat (0–360°) dari Utara.
  /// Return null jika gagal.
  static Future<double?> getQiblaDirection(double lat, double lng) async {
    final url = Uri.parse('$_base/qibla/$lat/$lng');
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['code'] == 200 && json['data'] != null) {
          final direction = json['data']['direction'];
          if (direction != null) {
            return (direction as num).toDouble();
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
