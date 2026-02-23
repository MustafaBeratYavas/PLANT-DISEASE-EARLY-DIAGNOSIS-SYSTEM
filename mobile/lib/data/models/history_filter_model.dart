// Time range options
enum DateFilter {
  last15Minutes,
  lastHour,
  last24Hours,
  lastWeek,
  lastMonth,
  allTime,
}

// Disease status options
enum HealthStatusFilter {
  all,
  healthy,
  infected,
}

class HistoryFilterModel {

  // Default filter configuration
  const HistoryFilterModel({
    this.dateFilter = DateFilter.allTime,
    this.healthFilter = HealthStatusFilter.all,
    this.selectedPlants = const {},
  });
  // Active time filter
  final DateFilter dateFilter;
  // Active health filter
  final HealthStatusFilter healthFilter;
  // Selected plant types
  final Set<String> selectedPlants;

  // Create modified copy
  HistoryFilterModel copyWith({
    DateFilter? dateFilter,
    HealthStatusFilter? healthFilter,
    Set<String>? selectedPlants,
  }) {
    return HistoryFilterModel(
      dateFilter: dateFilter ?? this.dateFilter,
      healthFilter: healthFilter ?? this.healthFilter,
      selectedPlants: selectedPlants ?? this.selectedPlants,
    );
  }
}