import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _expenseService = ExpenseService();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  Expense? _expense;
  String? _selectedCategory;
  DateTime? _expenseDate;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false;
  String? _error;

  String _normalizeDecimal(String text) => text.replaceAll(',', '.');

  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadExpense() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final expense = await _expenseService.getExpense(widget.expenseId);
      if (expense == null) {
        setState(() {
          _error = 'Gasto nÃ£o encontrado.';
          _isLoading = false;
        });
        return;
      }

      _populateControllers(expense);
      setState(() {
        _expense = expense;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar gasto: $e';
        _isLoading = false;
      });
    }
  }

  void _populateControllers(Expense expense) {
    _amountController.text = expense.amount.toStringAsFixed(2);
    _noteController.text = expense.note;
    _selectedCategory = expense.category;
    _expenseDate = expense.date;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _expenseDate = picked);
    }
  }

  Future<void> _saveEdits() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _expenseDate == null) {
      _showSnackBar('Preencha todos os campos.', AppColors.danger);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _expenseService.updateExpense(widget.expenseId, {
        'amount': double.parse(_normalizeDecimal(_amountController.text)),
        'category': _selectedCategory,
        'note': _noteController.text.trim(),
        'date': Timestamp.fromDate(_expenseDate!),
      });
      setState(() => _isEditMode = false);
      await _loadExpense();
      if (mounted) {
        _showSnackBar('Gasto atualizado!', AppColors.accent);
      }
    } catch (e) {
      _showSnackBar('Erro ao salvar: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Excluir gasto',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Tem certeza que deseja excluir este gasto? Esta aÃ§Ã£o nÃ£o pode ser desfeita.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await _expenseService.deleteExpense(widget.expenseId);
      if (mounted) {
        _showSnackBar('Gasto excluÃ­do.', AppColors.textSecondary);
        context.pop();
      }
    } catch (e) {
      _showSnackBar('Erro ao excluir: $e', AppColors.danger);
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detalhes do Gasto',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_expense != null && !_isEditMode)
            IconButton(
              onPressed: () => setState(() => _isEditMode = true),
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              tooltip: 'Editar',
            ),
          if (_isEditMode)
            IconButton(
              onPressed: () {
                _populateControllers(_expense!);
                setState(() => _isEditMode = false);
              },
              icon: const Icon(
                Icons.close,
                color: AppColors.textSecondary,
              ),
              tooltip: 'Cancelar ediÃ§Ã£o',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.danger,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadExpense,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final expense = _expense!;
    final sourceLabel = expense.source == 'telegram' ? 'Telegram' : 'App';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.note.isNotEmpty ? expense.note : expense.category,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(label: expense.category),
                    _Tag(label: sourceLabel),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'R\$ ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _isEditMode ? _buildEditCard() : _buildInfoCard(expense),
          const SizedBox(height: 24),
          if (_isEditMode)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveEdits,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 20),
                label: const Text(
                  'Salvar alteraÃ§Ãµes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => setState(() => _isEditMode = true),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    label: const Text(
                      'Editar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _deleteExpense,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text(
                      'Excluir',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Expense expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Categoria',
            value: expense.category,
          ),
          Divider(color: AppColors.divider, height: 1),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Data',
            value: _dateFormat.format(expense.date),
          ),
          Divider(color: AppColors.divider, height: 1),
          _InfoRow(
            icon: Icons.sync_alt_rounded,
            label: 'Origem',
            value: expense.source == 'telegram' ? 'Telegram' : 'App',
          ),
          Divider(color: AppColors.divider, height: 1),
          _InfoRow(
            icon: Icons.access_time_outlined,
            label: 'Criado em',
            value: _dateFormat.format(expense.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modo de ediÃ§Ã£o',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration(
                'Valor (R\$)',
                Icons.attach_money_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o valor';
                }
                final parsed = double.tryParse(_normalizeDecimal(value));
                if (parsed == null || parsed <= 0) {
                  return 'Valor invÃ¡lido';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: _inputDecoration(
                'Categoria',
                Icons.category_outlined,
              ),
              dropdownColor: AppColors.surfaceContainerLow,
              items: kExpenseCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecione uma categoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration(
                'DescriÃ§Ã£o',
                Icons.note_outlined,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: _inputDecoration(
                  'Data',
                  Icons.calendar_today_outlined,
                ),
                child: Text(
                  _expenseDate == null
                      ? 'Selecione uma data'
                      : _dateFormat.format(_expenseDate!),
                  style: TextStyle(
                    color: _expenseDate == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
