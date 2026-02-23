import 'package:flutter/foundation.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/history_filter_model.dart';
import '../../../data/models/scan_history_model.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../services/media/media_service.dart';

class HistoryController extends ChangeNotifier {

  // Constructor injection
  HistoryController(this._repository);
  final HistoryRepository _repository;
  List<ScanHistoryModel> _allHistory = [];
  List<ScanHistoryModel> _filteredHistory = [];
  HistoryFilterModel _filter = const HistoryFilterModel();

  // Public getters
  List<ScanHistoryModel> get history => List.unmodifiable(_filteredHistory);
  HistoryFilterModel get filter => _filter;

  // Reload scan history
  void loadHistory() {
    _allHistory = _repository.getHistory();
    _applyFilter();
  }

  // Add new scan
  Future<void> addScan(ScanHistoryModel scan) async {
    await _repository.saveScan(scan);
    loadHistory();
  }

  // Remove scan entry
  Future<void> deleteScan(String id) async {
    final itemIndex = _allHistory.indexWhere((element) => element.id == id);
    if (itemIndex != -1) {
      final item = _allHistory[itemIndex];
      final file = getIt<MediaService>().getFileFromStorage(item.imagePath);

      // Delete associated image
      if (await file.exists()) {
        await file.delete();
      }
      await _repository.deleteScan(id);
      loadHistory();
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    final mediaService = getIt<MediaService>();
    for (final item in _allHistory) {
      final file = mediaService.getFileFromStorage(item.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _repository.clearHistory();
    loadHistory();
  }

  // Update active filter
  void updateFilter(HistoryFilterModel newFilter) {
    _filter = newFilter;
    _applyFilter();
  }

  // Get available plants
  Set<String> getAvailablePlants() {
    return _allHistory.map((e) => _getPlantName(e.diseaseId)).toSet();
  }

  // Extract plant name
  String _getPlantName(String diseaseId) {
    return diseaseId.split('___').first.replaceAll('_', ' ');
  }

  // Apply active filters
  void _applyFilter() {
    _filteredHistory = _allHistory.where((scan) {
      final matchesDate = _checkDateFilter(scan.date);
      final matchesHealth = _checkHealthFilter(scan.diseaseId);
      final matchesPlant = _checkPlantFilter(scan.diseaseId);
      return matchesDate && matchesHealth && matchesPlant;
    }).toList();
    notifyListeners();
  }

  // Check date range
  bool _checkDateFilter(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    switch (_filter.dateFilter) {
      case DateFilter.last15Minutes:
        return difference.inMinutes <= 15;
      case DateFilter.lastHour:
        return difference.inHours <= 1;
      case DateFilter.last24Hours:
        return difference.inHours <= 24;
      case DateFilter.lastWeek:
        return difference.inDays <= 7;
      case DateFilter.lastMonth:
        return difference.inDays <= 30;
      case DateFilter.allTime:
        return true;
    }
  }

  // Check health status
  bool _checkHealthFilter(String diseaseId) {
    final isHealthy = diseaseId.toLowerCase().contains('healthy');
    switch (_filter.healthFilter) {
      case HealthStatusFilter.healthy:
        return isHealthy;
      case HealthStatusFilter.infected:
        return !isHealthy;
      case HealthStatusFilter.all:
        return true;
    }
  }

  // Check plant type
  bool _checkPlantFilter(String diseaseId) {
    if (_filter.selectedPlants.isEmpty) return true;
    final plantName = _getPlantName(diseaseId);
    return _filter.selectedPlants.contains(plantName);
  }
}