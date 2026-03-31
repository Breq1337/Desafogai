import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stitch_background.dart';
import '../providers/onboarding_provider.dart' as onboarding;
import '../widgets/onboarding_step_1_welcome.dart';
import '../widgets/onboarding_step_2_income.dart';
import '../widgets/onboarding_step_3_goal.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  double? _monthlyIncome;
  String? _selectedGoal;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboarding.completeOnboardingProvider(_monthlyIncome).future);
    if (mounted) context.go('/dashboard');
  }

  bool get _canContinue {
    if (_currentStep == 0) return true; // Welcome, always ok
    if (_currentStep == 1) return _monthlyIncome != null && _monthlyIncome! > 0;
    if (_currentStep == 2) return _selectedGoal != null;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StitchBackground(
        child: SafeArea(
        child: Column(
          children: [
            const StitchTopBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  minHeight: 3,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryContainer,
                  ),
                ),
              ),
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_currentStep + 1}/3',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  OnboardingStepWelcome(),
                  OnboardingStepIncome(
                    onIncomeChanged: (income) {
                      setState(() => _monthlyIncome = income);
                    },
                    initialValue: _monthlyIncome,
                  ),
                  OnboardingStepGoal(
                    onGoalSelected: (goal) {
                      setState(() => _selectedGoal = goal);
                    },
                    initialValue: _selectedGoal,
                  ),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Back button
                  if (_currentStep > 0)
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back_rounded),
                      ),
                    )
                  else
                    const SizedBox(width: 54),

                  const SizedBox(width: 12),

                  // Next/Complete button
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: _canContinue
                              ? const LinearGradient(
                                  colors: AppColors.ctaGradient,
                                )
                              : LinearGradient(
                                  colors: [
                                    AppColors.surfaceContainerHigh,
                                    AppColors.surfaceContainerHigh,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _canContinue
                              ? [
                                  BoxShadow(
                                    color: AppColors.ctaGlow,
                                    blurRadius: 18,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          onPressed: _canContinue ? _nextStep : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledForegroundColor: AppColors.textSecondary,
                          ),
                          child: Text(
                            _currentStep == 2 ? 'Iniciar missão' : 'Próximo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: _canContinue
                                  ? AppColors.onPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
