// lib/core/services/nexus_energy_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/nexus_energy_state.dart';
import '../models/daily_energy.dart';

class NexusEnergyService {
  final String baseUrl; // e.g. "http://192.168.1.170:8000"

  NexusEnergyService([this.baseUrl = "http://192.168.1.170:8000"]);

  Future<NexusEnergyState?> fetchEnergyState() async {
    try {
      final uri = Uri.parse("$baseUrl/api/energy/state");
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return NexusEnergyState.fromJson(data);
      } else {
        print("Energy API error: ${res.statusCode} ${res.body}");
        return null;
      }
    } catch (e) {
      print("Energy API exception: $e");
      return null;
    }
  }

  Future<DailyEnergy?> fetchDailyTotals() async {
    try {
      final uri = Uri.parse("$baseUrl/api/energy/daily");
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return DailyEnergy.fromJson(data);
      } else {
        print("Daily API error: ${res.statusCode} ${res.body}");
        return null;
      }
    } catch (e) {
      print("Daily API exception: $e");
      return null;
    }
  }
}
