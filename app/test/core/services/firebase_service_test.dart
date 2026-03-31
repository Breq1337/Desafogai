import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/core/services/firebase_service.dart';

void main() {
  group('FirebaseService', () {
    test('class is accessible and has init method', () {
      // Verify the service class exists and exposes init.
      // Actual Firebase initialisation requires platform bindings
      // and is covered by integration tests.
      expect(FirebaseService.init, isA<Function>());
    });
  });
}
