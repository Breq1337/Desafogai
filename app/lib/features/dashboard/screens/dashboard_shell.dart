import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/providers/expenses_provider.dart';
import '../../expenses/screens/expenses_screen.dart';
import '../models/debt_model.dart';
import '../providers/debts_provider.dart';
import '../providers/income_provider.dart';
import 'chat_screen.dart';
import 'dashboard_screen.dart';
import 'monthly_plan_screen.dart';
import 'settings_screen.dart';
import 'simulator_screen.dart';

/// Shell com bottom navigation que envolve todas as telas do dashboard
class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  int _currentIndex = 0;

  static const _navItems = [
    _NavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Inicio'),
    _NavItem(Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Gastos'),
    _NavItem(Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Plano'),
    _NavItem(Icons.analytics_rounded, Icons.analytics_outlined, 'Simulador'),
    _NavItem(Icons.smart_toy_rounded, Icons.smart_toy_outlined, 'IA Chat'),
    _NavItem(Icons.settings_rounded, Icons.settings_outlined, 'Config'),
  ];

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsProvider);
    final isDemoUser = ref.watch(isDemoUserProvider);
    final incomeAsync = ref.watch(monthlyIncomeProvider);
    final expenseTotalAsync = ref.watch(monthlyExpenseTotalProvider);

    final List<Debt> debts = debtsAsync.valueOrNull ??
        (isDemoUser ? ref.watch(mockDebtsProvider) : <Debt>[]);

    final monthlyIncome = incomeAsync.valueOrNull ?? 0.0;
    final fixedExpenses = expenseTotalAsync.valueOrNull ?? 0.0;

    final screens = [
      const DashboardScreen(),
      const ExpensesScreen(),
      MonthlyPlanScreen(
        debts: debts,
        monthlyIncome: monthlyIncome,
        fixedExpenses: fixedExpenses,
      ),
      SimulatorScreen(
        debts: debts,
        monthlyIncome: monthlyIncome,
        fixedExpenses: fixedExpenses,
      ),
      ChatScreen(
        debts: debts,
        monthlyIncome: monthlyIncome,
        fixedExpenses: fixedExpenses,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _GlassBottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(
                color: Color(0x20FFFFFF),
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final isSelected = index == currentIndex;
                final item = items[index];
                return _NavButton(
                  icon: isSelected ? item.activeIcon : item.inactiveIcon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Icon(
                icon,
                size: isSelected ? 24 : 22,
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
            // Glow dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(top: 3),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.55,
                          ),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
