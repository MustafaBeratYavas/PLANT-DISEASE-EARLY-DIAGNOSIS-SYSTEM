class DiseaseDetailModel {
  // Unique disease identifier
  final String id;
  // Observable disease symptoms
  final List<String> symptoms;
  // Curative treatment methods
  final List<String> treatment;
  // Preventive care measures
  final List<String> prevention;

  // Immutable data constructor
  const DiseaseDetailModel({
    required this.id,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
  });
}