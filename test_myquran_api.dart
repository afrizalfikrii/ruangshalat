import 'dart:convert';
import 'package:http/http.dart' as http;
void main() async {
  final url = Uri.parse('https://equran.id/api/v2/surat/1');
  final res = await http.get(url);
  final json = jsonDecode(res.body);
  print(json['data'].keys.toList());
  if (json['data'].containsKey('ayat')) {
     print(json['data']['ayat'][0].keys.toList());
  }
}
