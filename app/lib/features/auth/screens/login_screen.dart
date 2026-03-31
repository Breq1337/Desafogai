import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_error_messages.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } catch (e) {
      if (mounted) setState(() => _error = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) setState(() => _error = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInAsDemo() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signInAsDemo();
    } catch (e) {
      if (mounted) setState(() => _error = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient glow at top
          Positioned(
            top: -screenHeight * 0.15,
            left: -80,
            right: -80,
            child: Container(
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // Logo
                        Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.ctaGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.cloud_off_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Desafog.ai',
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Saia das dívidas com inteligência',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Error
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: AppColors.danger, size: 18),
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

                        // Email
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'E-mail',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe seu e-mail';
                            }
                            if (!v.contains('@')) return 'E-mail inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Password
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Senha',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _signInWithEmail(),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Informe sua senha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 4),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/auth/forgot-password'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                            child: Text(
                              'Esqueci minha senha',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Sign in button
                        _PrimaryButton(
                          label: 'Entrar',
                          loading: _loading,
                          onPressed: _signInWithEmail,
                        ),
                        const SizedBox(height: 28),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: AppColors.divider),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou continue com',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: AppColors.divider),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Google
                        SocialSignInButton(
                          label: 'Google',
                          icon: Icons.g_mobiledata_rounded,
                          iconColor: AppColors.accent,
                          onPressed: _loading ? null : _signInWithGoogle,
                        ),
                        const SizedBox(height: 12),

                        // Demo
                        SocialSignInButton(
                          label: 'Modo demonstração',
                          icon: Icons.explore_outlined,
                          iconColor: AppColors.primary,
                          onPressed: _loading ? null : _signInAsDemo,
                        ),
                        const SizedBox(height: 36),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Não tem conta? ',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/auth/register'),
                              child: Text(
                                'Criar conta',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.ctaGradient,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
