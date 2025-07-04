import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:relieflink/models/incident.dart';

class IncidentService {
  static const String _incidentsKey = 'incidents';

  Future<List<Incident>> getIncidents() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_incidentsKey) ?? [];
    return data.map((e) => Incident.fromJson(jsonDecode(e))).toList();
  }

  Future<void> addIncident(Incident incident) async {
    final prefs = await SharedPreferences.getInstance();
    final incidents = await getIncidents();
    incidents.insert(0, incident); // newest first
    final data = incidents.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_incidentsKey, data);
  }

  Future<void> syncToCloud(Incident incident) async {
    // TODO: Implement cloud sync
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> shareViaMesh(Incident incident) async {
    // TODO: Implement mesh network sharing
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
