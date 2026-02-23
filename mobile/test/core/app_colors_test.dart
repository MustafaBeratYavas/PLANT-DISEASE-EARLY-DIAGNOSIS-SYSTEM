import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_colors.dart';

void main() {
  group('AppColors', () {
    group('getConfidenceColor', () {
      test('returns green for high confidence (>= 0.8)', () {
        expect(AppColors.getConfidenceColor(0.8), AppColors.confidenceHigh);
        expect(AppColors.getConfidenceColor(0.9), AppColors.confidenceHigh);
        expect(AppColors.getConfidenceColor(1.0), AppColors.confidenceHigh);
      });

      test('returns orange for medium confidence (0.5-0.8)', () {
        expect(AppColors.getConfidenceColor(0.5), AppColors.confidenceMedium);
        expect(AppColors.getConfidenceColor(0.65), AppColors.confidenceMedium);
        expect(AppColors.getConfidenceColor(0.79), AppColors.confidenceMedium);
      });

      test('returns red for low confidence (< 0.5)', () {
        expect(AppColors.getConfidenceColor(0.0), AppColors.confidenceLow);
        expect(AppColors.getConfidenceColor(0.3), AppColors.confidenceLow);
        expect(AppColors.getConfidenceColor(0.49), AppColors.confidenceLow);
      });
    });

    test('primary colors are defined correctly', () {
      expect(AppColors.primary.value, 0xFF2E7D32);
      expect(AppColors.primaryLight.value, 0xFF4CAF50);
      expect(AppColors.primaryDark.value, 0xFF1B5E20);
    });

    test('status colors match Material Design', () {
      expect(AppColors.success.value, 0xFF2E7D32);
      expect(AppColors.warning.value, 0xFFF57C00);
      expect(AppColors.error.value, 0xFFD32F2F);
    });
  });
}
