import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../models/debt_model.dart';
import '../widgets/debt_detail_actions.dart';
import '../widgets/debt_detail_header.dart';
import '../widgets/debt_detail_info_card.dart';

class DebtDetailScreen extends ConsumerStatefulWidget {
  final String debtId;
  const DebtDetailScreen({super.key, required this.debtId});

  @override
  ConsumerState<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends ConsumerState<DebtDetailScreen> {
  Debt? _debt;
  bool _isLoading = true;
  String? _error;
  bool _isEditMode = false;
  bool _isSaving = false;

  late TextEditingController _amountController;
  late TextEditingController _rateController;
  late TextEditingController _minPaymentController;
  late TextEditingController _dueDateController;
  DateTime? _editDueDate;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _rateController = TextEditingController();
    _minPaymentController = TextEditingController();
    _dueDateController = TextEditingController();
    _loadDebt();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _minPaymentController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  DocumentReference _debtRef() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('debts')
        .doc(widget.debtId);
  }

  Future<void> _loadDebt() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final doc = await _debtRef().get();
      if (!doc.exists) {
        setState(() {
          _error = 'Dívida não encontrada.';
          _isLoading = false;
        });
        return;
      }
      final debt = Debt.fromFirestore(doc);
      _populateControllers(debt);
      setState(() {
        _debt = debt;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar dívida: $e';
        _isLoading = false;
      });
    }
  }

  void _populateControllers(Debt debt) {
    _amountController.text = debt.amount.toStringAsFixed(2);
    _rateController.text = debt.interestRate.toStringAsFixed(2);
    _minPaymentController.text = debt.minimumPayment.toStringAsFixed(2);
    _dueDateController.text = _dateFormat.format(debt.dueDate);
    _editDueDate = debt.dueDate;
  }

  Future<void> _markAsPaid() async {
    setState(() => _isSaving = true);
    try {
      await _debtRef().update({'status': 'paid'});
      await _loadDebt();
      if (mounted) {
        _showSnackBar('Dívida marcada como paga!', AppColors.accent);
      }
    } catch (e) {
      _showSnackBar('Erro: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _togglePause() async {
    final debt = _debt!;
    final newStatus = debt.status == 'paused' ? 'active' : 'paused';
    final label = newStatus == 'paused' ? 'pausada' : 'reativada';

    setState(() => _isSaving = true);
    try {
      await _debtRef().update({'status': newStatus});
      await _loadDebt();
      if (mounted) {
        _showSnackBar('Dívida $label!', AppColors.accent);
      }
    } catch (e) {
      _showSnackBar('Erro: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _reactivate() async {
    setState(() => _isSaving = true);
    try {
      await _debtRef().update({'status': 'active'});
      await _loadDebt();
      if (mounted) {
        _showSnackBar('Dívida reativada!', AppColors.accent);
      }
    } catch (e) {
      _showSnackBar('Erro: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteDebt() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Excluir dívida',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Tem certeza que deseja excluir a dívida com '
          '"${_debt?.creditor}"? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: AppColors.textSecondary),
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
      await _debtRef().delete();
      if (mounted) {
        _showSnackBar('Dívida excluída.', AppColors.textSecondary);
        context.pop();
      }
    } catch (e) {
      _showSnackBar('Erro ao excluir: $e', AppColors.danger);
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveEdits() async {
    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );
    final rate = double.tryParse(
      _rateController.text.replaceAll(',', '.'),
    );
    final minPayment = double.tryParse(
      _minPaymentController.text.replaceAll(',', '.'),
    );

    if (amount == null ||
        rate == null ||
        minPayment == null ||
        _editDueDate == null) {
      _showSnackBar(
        'Preencha todos os campos corretamente.',
        AppColors.danger,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _debtRef().update({
        'amount': amount,
        'interestRate': rate,
        'minimumPayment': minPayment,
        'dueDate': Timestamp.fromDate(_editDueDate!),
      });
      setState(() => _isEditMode = false);
      await _loadDebt();
      if (mounted) {
        _showSnackBar('Dívida atualizada!', AppColors.accent);
      }
    } catch (e) {
      _showSnackBar('Erro ao salvar: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _editDueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
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
      setState(() {
        _editDueDate = picked;
        _dueDateController.text = _dateFormat.format(picked);
      });
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

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        'Detalhes da Dívida',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_debt != null && !_isEditMode)
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            onPressed: () => setState(() => _isEditMode = true),
            tooltip: 'Editar',
          ),
        if (_isEditMode)
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: () {
              _populateControllers(_debt!);
              setState(() => _isEditMode = false);
            },
            tooltip: 'Cancelar edição',
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) return _buildErrorState();

    final debt = _debt!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DebtDetailHeader(debt: debt),
          const SizedBox(height: 16),
          _buildWarnings(debt),
          _isEditMode
              ? DebtDetailEditCard(
                  amountController: _amountController,
                  rateController: _rateController,
                  minPaymentController: _minPaymentController,
                  dueDateController: _dueDateController,
                  onPickDate: _pickDueDate,
                )
              : DebtDetailInfoCard(debt: debt),
          const SizedBox(height: 16),
          DebtUrgencyCard(debt: debt),
          const SizedBox(height: 24),
          if (_isEditMode)
            DebtDetailSaveButton(isSaving: _isSaving, onSave: _saveEdits)
          else
            DebtDetailActionButtons(
              debt: debt,
              isSaving: _isSaving,
              onMarkPaid: _markAsPaid,
              onEdit: () => setState(() => _isEditMode = true),
              onDelete: _deleteDebt,
              onTogglePause: _togglePause,
              onReactivate: _reactivate,
            ),
        ],
      ),
    );
  }

  Widget _buildWarnings(Debt debt) {
    if (debt.status != 'active') return const SizedBox.shrink();

    if (debt.isOverdue) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: DebtWarningBanner(
          icon: Icons.warning_amber_rounded,
          text: 'Esta dívida está vencida!',
          color: AppColors.danger,
        ),
      );
    }

    if (debt.isDueSoon) {
      final daysLeft = debt.dueDate.difference(DateTime.now()).inDays;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DebtWarningBanner(
          icon: Icons.schedule,
          text: 'Vence em $daysLeft dias',
          color: AppColors.warning,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorState() {
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
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDebt,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
