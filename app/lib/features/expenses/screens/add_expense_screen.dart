import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/config_service.dart';
import '../../dashboard/providers/ai_chat_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/voice_input_button.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../services/voice_expense_extractor.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategory;
  DateTime? _expenseDate;
  bool _loading = false;
  bool _extracting = false;
  String? _error;
  final _expenseService = ExpenseService();

  String _normalizeDecimal(String text) => text.replaceAll(',', '.');

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _expenseDate = picked);
    }
  }

  Future<void> _extractFromVoice(String rawText) async {
    if (!ConfigService.isDesafogAiBackendConfigured()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Defina DESAFOG_API_BASE_URL no .env para usar voz com IA.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _extracting = true);

    try {
      final api = ref.read(desafogApiClientProvider);
      final extractor = VoiceExpenseExtractor(api: api);
      final data = await extractor.extract(rawText);

      if (mounted && data.hasAnyField) {
        setState(() {
          if (data.amount != null) _amountController.text = data.amount!.toStringAsFixed(2);
          if (data.category != null) _selectedCategory = data.category;
          if (data.note != null) _noteController.text = data.note!;
          if (data.date != null) _expenseDate = data.date;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Campos preenchidos por voz — confira antes de salvar'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não consegui extrair dados. Tente ser mais específico.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na extração: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _extracting = false);
    }
  }

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null || _expenseDate == null) {
      setState(() => _error = 'Preencha todos os campos');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _error = 'Usuário não autenticado');
        return;
      }

      final expense = Expense(
        id: '',
        amount: double.parse(_normalizeDecimal(_amountController.text)),
        category: _selectedCategory!,
        note: _noteController.text.trim(),
        date: _expenseDate!,
        source: 'app',
        createdAt: DateTime.now(),
      );

      await _expenseService.createExpense(expense);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto adicionado com sucesso!')),
        );
      }
    } catch (e) {
      setState(() => _error = 'Erro ao adicionar gasto: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Novo gasto'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Registrar gasto',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados do seu gasto',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Voice input banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryContainer.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      VoiceInputButton(
                        size: 40,
                        enabled: !_extracting,
                        onResult: _extractFromVoice,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _extracting
                                  ? 'Processando...'
                                  : 'Preencher por voz',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Diga: "Gastei 50 no almoço"',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_extracting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Error banner
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.danger,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Amount field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor (R\$)',
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+[.,]?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: '0,00',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o valor';
                        }
                        final parsed = double.tryParse(_normalizeDecimal(value));
                        if (parsed == null || parsed <= 0) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categoria',
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'Selecione uma categoria',
                        prefixIcon: const Icon(Icons.category_rounded),
                      ),
                      items: kExpenseCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma categoria';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descrição (opcional)',
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      keyboardType: TextInputType.text,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Ex: Almoço no restaurante',
                        prefixIcon: const Icon(Icons.note_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data',
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _expenseDate != null
                                ? AppColors.primary
                                : AppColors.divider,
                            width: _expenseDate != null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _expenseDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_expenseDate!)
                                  : 'Selecione uma data',
                              style: textTheme.bodyMedium?.copyWith(
                                color: _expenseDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              color: _expenseDate != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_expenseDate == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Data obrigatória',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _loading
                          ? LinearGradient(
                              colors: [
                                AppColors.divider,
                                AppColors.divider,
                              ],
                            )
                          : const LinearGradient(
                              colors: AppColors.ctaGradient,
                            ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _loading
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.ctaGlow,
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _addExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledForegroundColor: AppColors.textSecondary,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Text(
                              'Adicionar gasto',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: AppColors.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
