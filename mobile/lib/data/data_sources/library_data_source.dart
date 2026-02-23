import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/disease_detail_model.dart';

class LibraryDataSource {
  // Fetch disease details
  static Future<DiseaseDetailModel?> getDetail(String diseaseId, String languageCode) async {
    try {
      // Resolve localized file
      final String fileName = languageCode == 'tr' ? 'diseases_tr.json' : 'diseases_en.json';
      
      // Load data asset
      final String jsonString = await rootBundle.loadString('assets/data/$fileName');
      // Decode JSON string
      final Map<String, dynamic> decodedJson = json.decode(jsonString) as Map<String, dynamic>;

      // Find the specific disease data using diseaseId
      final Map<String, dynamic>? diseaseData = decodedJson[diseaseId] as Map<String, dynamic>?;

      if (diseaseData == null) {
        return null; // Disease not found
      }

      // Map to model
      return DiseaseDetailModel(
        id: diseaseId,
        symptoms: List<String>.from(diseaseData['symptoms'] as List<dynamic>),
        treatment: List<String>.from(diseaseData['treatment'] as List<dynamic>),
        prevention: List<String>.from(diseaseData['prevention'] as List<dynamic>),
      );
    } catch (e) {
      // Handle load errors
      return null;
    }
  }
}