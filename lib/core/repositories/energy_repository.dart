import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:nexus_app/core/models/nexus_energy_state.dart';
import 'package:nexus_app/core/models/daily_energy.dart';

class NexusEnergyRepository {
  final String baseUrl;

  NexusEnergyRepository({required this.baseUrl});

  // ============================================================
  // FETCH LIVE ENERGY STATE (Zappi + Legacy Nexus fields)
  // ============================================================
  Future<NexusEnergyState> fetchEnergyState() async {
    final url = Uri.parse('$baseUrl/api/energy/state');
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to load energy state: ${res.body}');
    }

    return NexusEnergyState.fromJson(jsonDecode(res.body));
  }

  // ============================================================
  // FETCH DAILY CUMULATIVE TOTALS (NEW)
  // ============================================================
  Future<DailyEnergy> fetchDailyTotals() async {
    final url = Uri.parse('$baseUrl/api/energy/daily');
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to load daily totals: ${res.body}');
    }

    return DailyEnergy.fromJson(jsonDecode(res.body));
  }

  // ============================================================
  // GRID ISOLATOR CONTROL
  // ============================================================
  Future<void> toggleGridIsolator() async {
    final url = Uri.parse('$baseUrl/grid/isolator/toggle');
    final res = await http.post(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to toggle grid isolator: ${res.body}');
    }
  }

  // ============================================================
  // EV CHARGING CONTROLS
  // ============================================================
  Future<void> pauseCharging() async {
    final url = Uri.parse('$baseUrl/ev/pause');
    final res = await http.post(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to pause EV charging: ${res.body}');
    }
  }

  Future<void> resumeFastCharging() async {
    final url = Uri.parse('$baseUrl/ev/resume_fast');
    final res = await http.post(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to resume fast charging: ${res.body}');
    }
  }

  Future<void> resumeEcoCharging() async {
    final url = Uri.parse('$baseUrl/ev/resume_eco');
    final res = await http.post(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to resume eco charging: ${res.body}');
    }
  }

  // ============================================================
  // EV SCHEDULING
  // ============================================================
  Future<void> startSchedule(DateTime start, DateTime end) async {
    final url = Uri.parse('$baseUrl/ev/schedule/start');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to start EV schedule: ${res.body}');
    }
  }

  Future<void> stopSchedule() async {
    final url = Uri.parse('$baseUrl/ev/schedule/stop');
    final res = await http.post(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to stop EV schedule: ${res.body}');
    }
  }

  Future<void> finishBy(DateTime deadline, int targetSoc) async {
    final url = Uri.parse('$baseUrl/ev/schedule/finish_by');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deadline': deadline.toIso8601String(),
        'target_soc': targetSoc,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to set EV finish-by schedule: ${res.body}');
    }
  }
}
