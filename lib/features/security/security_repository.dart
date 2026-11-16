import 'package:nexus_app/core/repositories/base_repository.dart';

class SecurityRepository extends BaseRepository {
  SecurityRepository({required super.baseUrl});

  Future<Map<String, dynamic>> getStatus() async {
    return await get('/security/status');
  }

  Future<Map<String, dynamic>> arm() async {
    return await post('/security/arm');
  }

  Future<Map<String, dynamic>> disarm() async {
    return await post('/security/disarm');
  }
}
