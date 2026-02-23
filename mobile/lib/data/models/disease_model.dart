class DiseaseModel {
  // Unique identifier
  final String id;
  // Localization resource key
  final String localizationKey;
  // Thumbnail asset path
  final String thumbnailPath;

  // Standard immutable constructor
  const DiseaseModel({
    required this.id,
    required this.localizationKey,
    required this.thumbnailPath,
  });
}