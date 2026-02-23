class ScanHistoryModel {

  ScanHistoryModel({
    required this.id,
    required this.imagePath,
    required this.diseaseId,
    required this.confidence,
    required this.date,
  });

  // Deserialize from JSON map
  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      diseaseId: json['diseaseId'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
  // Unique record identifier
  final String id;
  // Stored image file path
  final String imagePath;
  // Detected disease key
  final String diseaseId;
  // Prediction confidence score
  final double confidence;
  // Scan creation timestamp
  final DateTime date;

  // Serialize to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'diseaseId': diseaseId,
      'confidence': confidence,
      'date': date.toIso8601String(),
    };
  }
}