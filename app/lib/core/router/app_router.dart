import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/add_debt_screen.dart';
import '../../features/dashboard/screens/dashboard_shell.dart';
import '../../features/dashboard/screens/debt_detail_screen.dart';
import '../../features/expenses/screens/add_expense_screen.dart';
import '../../features/expenses/screens/budget_screen.dart';
import '../../features/expenses/screens/cashflow_screen.dart';
import '../../features/expenses/screens/expense_detail_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import 'router_notifier.dart';

abstract final class AppRoutes {
  static const auth = '/auth';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const addExpense = '/dashboard/expenses/add';
  static const expenses = '/dashboard/expenses';
  static const budget = '/dashboard/expenses/budget';
  static const cashflow = '/dashboard/expenses/cashflow';
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.auth,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final location = state.matchedLocation;
      final isOnAuthRoute = location.startsWith(AppRoutes.auth);
      final isOnOnboardingRoute = location.startsWith(AppRoutes.onboarding);

      // Still loading auth state — don't redirect yet
      if (authState.isLoading) return null;

      // Not logged in → force to auth
      if (!isLoggedIn && !isOnAuthRoute) {
        return AppRoutes.auth;
      }

      if (isLoggedIn) {
        final onboardingState = ref.read(onboardingCompletedProvider);
        if (onboardingState.isLoading) return null;
        final completed = onboardingState.valueOrNull ?? false;

        if (isOnAuthRoute) {
          return completed ? AppRoutes.dashboard : AppRoutes.onboarding;
        }

        if (isOnOnboardingRoute && completed) {
          return AppRoutes.dashboard;
        }

        if (!isOnOnboardingRoute && !completed) {
          return AppRoutes.onboarding;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardShell(),
        routes: [
          GoRoute(
            path: 'add-debt',
            builder: (context, state) => const AddDebtScreen(),
          ),
          GoRoute(
            path: 'debt/:id',
            builder: (context, state) {
              final debtId = state.pathParameters['id']!;
              return DebtDetailScreen(debtId: debtId);
            },
          ),
          GoRoute(
            path: 'expenses/add',
            builder: (context, state) => const AddExpenseScreen(),
          ),
          GoRoute(
            path: 'expenses/:id',
            builder: (context, state) {
              final expenseId = state.pathParameters['id']!;
              return ExpenseDetailScreen(expenseId: expenseId);
            },
          ),
          GoRoute(
            path: 'expenses/budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: 'expenses/cashflow',
            builder: (context, state) => const CashflowScreen(),
          ),
        ],
      ),
    ],
  );
});
