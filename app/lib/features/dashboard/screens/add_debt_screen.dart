import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/config_service.dart';
import '../providers/ai_chat_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/voice_input_button.dart';
import '../models/debt_model.dart';
import '../services/voice_debt_extractor.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _creditorController = TextEditingController();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _minPaymentController = TextEditingController();

  DateTime? _dueDate;
  bool _loading = false;
  bool _extracting = false;
  String? _error;
  bool _submitted = false;

  String _normalizeDecimal(String text) => text.replaceAll(',', '.');

  @override
  void dispose() {
    _creditorController.dispose();
    _amountController.dispose();
    _rateController.dispose();
    _minPaymentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
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
      final extractor = VoiceDebtExtractor(api: api);
      final data = await extractor.extract(rawText);

      if (mounted && data.hasAnyField) {
        setState(() {
          if (data.creditor != null) _creditorController.text = data.creditor!;
          if (data.amount != null) _amountController.text = data.amount!.toStringAsFixed(2);
          if (data.interestRate != null) _rateController.text = data.interestRate!.toStringAsFixed(2);
          if (data.minimumPayment != null) _minPaymentController.text = data.minimumPayment!.toStringAsFixed(2);
          if (data.dueDate != null) _dueDate = data.dueDate;
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

  void _showRateHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.percent_rounded, color: AppColors.primaryContainer, size: 22),
            const SizedBox(width: 10),
            const Text(
              'Taxa % a.m.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A taxa % a.m. (ao mês) indica quanto de juros é cobrado por mês sobre o valor da sua dívida.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Como descobrir:',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _helpItem('Fatura do cartão: procure "Encargos" ou "CET mensal"'),
                  _helpItem('Empréstimo: veja o contrato ou extrato do banco'),
                  _helpItem('Carnê/loja: peça ao atendente a taxa mensal'),
                  _helpItem('Se não souber, use 3% como estimativa conservadora'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Exemplo: se sua dívida é R\$ 1.000 com taxa de 5% a.m., no próximo mês os juros serão R\$ 50.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendi', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _helpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: AppColors.primaryContainer, fontWeight: FontWeight.w700)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDebt() async {
    setState(() => _submitted = true);

    if (!_formKey.currentState!.validate() || _dueDate == null) {
      setState(() => _error = _dueDate == null
          ? 'Selecione a data de vencimento'
          : 'Preencha todos os campos obrigatórios');
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

      final minPayText = _normalizeDecimal(_minPaymentController.text.trim());
      final debt = Debt(
        id: '',
        creditor: _creditorController.text.trim(),
        amount: double.parse(_normalizeDecimal(_amountController.text)),
        interestRate: double.parse(_normalizeDecimal(_rateController.text)),
        minimumPayment: minPayText.isNotEmpty ? double.parse(minPayText) : 0,
        dueDate: _dueDate!,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('debts')
          .add(debt.toFirestore());

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dívida adicionada com sucesso!')),
        );
      }
    } catch (e) {
      setState(() => _error = 'Erro ao adicionar dívida: $e');
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
        title: const Text('Nova dívida'),
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
                  'Informações da dívida',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados para registrar sua dívida',
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
                              'Diga: "Devo 5 mil pro Banco X, juros 2.5% ao mês"',
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

                // Creditor field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credor',
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _creditorController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Ex: Banco XYZ, Cartão Crédito',
                        prefixIcon: const Icon(Icons.business_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o credor';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount and Rate row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
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
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Taxa (% a.m.)',
                                style: textTheme.labelMedium,
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showRateHelp(context),
                                child: Icon(
                                  Icons.help_outline_rounded,
                                  size: 18,
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _rateController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+[.,]?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText: '0,0',
                              prefixIcon: const Icon(Icons.percent_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Informe a taxa';
                              }
                              if (double.tryParse(_normalizeDecimal(value)) == null) {
                                return 'Taxa inválida';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Pagamento mínimo (R\$)',
                          style: textTheme.labelMedium,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'opcional',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _minPaymentController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+[.,]?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Ex: 150,00',
                        prefixIcon: const Icon(Icons.receipt_long_rounded),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final parsed = double.tryParse(_normalizeDecimal(value));
                          if (parsed == null || parsed < 0) {
                            return 'Valor inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Due date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vencimento',
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
                            color: _dueDate != null
                                ? AppColors.primary
                                : AppColors.divider,
                            width: _dueDate != null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dueDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                                  : 'Selecione uma data',
                              style: textTheme.bodyMedium?.copyWith(
                                color: _dueDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              color: _dueDate != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_submitted && _dueDate == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Selecione a data de vencimento',
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
                      onPressed: _loading ? null : _addDebt,
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
                              'Adicionar dívida',
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
