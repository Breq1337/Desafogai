import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';

/// Bridges Riverpod auth + onboarding state → GoRouter's refreshListenable.
/// GoRouter re-evaluates its redirect callback whenever this notifies.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (prev, next) => notifyListeners());
    ref.listen(onboardingCompletedProvider, (prev, next) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
