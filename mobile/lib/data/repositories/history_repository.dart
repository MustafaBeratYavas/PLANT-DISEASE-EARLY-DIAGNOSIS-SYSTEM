import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history_model.dart';

class HistoryRepository {
  final SharedPreferences _prefs;
  static const String _keyHistory = 'scan_history';

  // Inject dependencies
  HistoryRepository(this._prefs);

  // Get all history
  List<ScanHistoryModel> getHistory() {
    final List<String>? jsonList = _prefs.getStringList(_keyHistory);
    if (jsonList == null) return [];

    // Decode and sort
    return jsonList
        .map((e) => ScanHistoryModel.fromJson(json.decode(e)))
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Save new scan
  Future<void> saveScan(ScanHistoryModel scan) async {
    final List<ScanHistoryModel> currentList = getHistory();
    currentList.add(scan);
    await _saveList(currentList);
  }

  // Delete scan item
  Future<void> deleteScan(String id) async {
    final List<ScanHistoryModel> currentList = getHistory();
    currentList.removeWhere((item) => item.id == id);
    await _saveList(currentList);
  }

  // Clear all data
  Future<void> clearHistory() async {
    await _prefs.remove(_keyHistory);
  }

  // Persist to storage
  Future<void> _saveList(List<ScanHistoryModel> list) async {
    final List<String> jsonList = list
        .map((e) => json.encode(e.toJson()))
        .toList();
    await _prefs.setStringList(_keyHistory, jsonList);
  }
}