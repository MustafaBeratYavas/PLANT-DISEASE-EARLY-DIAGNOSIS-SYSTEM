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
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      final diseaseData = jsonMap[diseaseId];

      // Validate data existence
      if (diseaseData == null) return null;

      // Map to model
      return DiseaseDetailModel(
        id: diseaseId,
        symptoms: List<String>.from(diseaseData['symptoms']),
        treatment: List<String>.from(diseaseData['treatment']),
        prevention: List<String>.from(diseaseData['prevention']),
      );
    } catch (e) {
      // Handle load errors
      return null;
    }
  }
}