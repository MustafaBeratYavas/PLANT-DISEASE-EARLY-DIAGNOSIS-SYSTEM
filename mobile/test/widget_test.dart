import 'package:flutter_test/flutter_test.dart';

import 'core/app_colors_test.dart' as app_colors;
import 'core/error_handler_test.dart' as error_handler;
import 'data/models_test.dart' as models;
import 'utils/disease_label_mapper_test.dart' as disease_label_mapper;

void main() {
  group('GreenHealer App Tests', () {
    // Run all test suites
    disease_label_mapper.main();
    app_colors.main();
    error_handler.main();
    models.main();
  });
}
