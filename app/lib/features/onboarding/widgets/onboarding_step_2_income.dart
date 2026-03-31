import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingStepIncome extends StatefulWidget {
  const OnboardingStepIncome({
    super.key,
    required this.onIncomeChanged,
    this.initialValue,
  });

  final Function(double?) onIncomeChanged;
  final double? initialValue;

  @override
  State<OnboardingStepIncome> createState() => _OnboardingStepIncomeState();
}

class _OnboardingStepIncomeState extends State<OnboardingStepIncome> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue != null
          ? widget.initialValue!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateIncome() {
    final value = double.tryParse(_controller.text);
    widget.onIncomeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.06),

          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.wallet_rounded,
              color: AppColors.accent,
              size: 48,
            ),
          ),
          SizedBox(height: screenHeight * 0.05),

          // Title
          Text(
            'Renda mensal',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Informe sua renda mensal bruta (antes de descontos)',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.08),

          // Input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Renda mensal',
                style: textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'),
                  ),
                ],
                onChanged: (_) => _updateIncome(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: '0,00',
                  prefixText: 'R\$ ',
                  prefixStyle: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.12),
        ],
      ),
    );
  }
}
