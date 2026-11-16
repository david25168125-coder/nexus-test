import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'water_status.dart';

class WaterService {
  final String baseUrl;

  WaterService(this.baseUrl);

  // Shared HTTP client with timeout
  final Duration _timeout = const Duration(seconds: 5);

  Future<WaterStatus?> getStatus() async {
    try {
      final url = Uri.parse('$baseUrl/api/water/status');
      final res = await http.get(url).timeout(_timeout);

      if (res.statusCode == 200) {
        return WaterStatus.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      print("WaterService.getStatus ERROR: $e");
    }
    return null; // return null safely if offline
  }

  Future<bool> openValve() async {
    return _postAction('/api/water/valve', {'action': 'open'});
  }

  Future<bool> closeValve() async {
    return _postAction('/api/water/valve', {'action': 'close'});
  }

  Future<bool> lockValve() async {
    return _postAction('/api/water/lock', {'action': 'lock'});
  }

  Future<bool> unlockValve() async {
    return _postAction('/api/water/lock', {'action': 'unlock'});
  }

  Future<bool> _postAction(String path, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['success'] == true;
      }
    } catch (e) {
      print("WaterService._postAction ERROR: $e");
    }

    return false; // fail safely
  }
}
