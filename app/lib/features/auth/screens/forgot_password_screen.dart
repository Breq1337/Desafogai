import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_error_messages.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordReset(_emailController.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = authErrorMessage(e));
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _sent ? _buildSuccess(textTheme) : _buildForm(textTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess(TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: AppColors.accent,
        ),
        const SizedBox(height: 24),
        Text(
          'E-mail enviado!',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Voltar ao login'),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(TextTheme textTheme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Redefinir senha',
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Informe seu e-mail para receber o link de redefinição',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _error!,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.danger,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          AuthTextField(
            controller: _emailController,
            hintText: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendReset(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe seu e-mail';
              }
              if (!value.contains('@')) {
                return 'E-mail inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _sendReset,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : const Text('Enviar link'),
            ),
          ),
        ],
      ),
    );
  }
}
