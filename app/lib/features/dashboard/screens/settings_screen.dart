import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';

import '../../../core/services/config_service.dart';
import '../../../core/services/telegram_link_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Feature flags
  bool _aiChatEnabled = false;
  bool _simulatorEnabled = false;
  bool _monthlyPlanEnabled = false;
  String _appEnvironment = '';
  String _appVersion = '...';

  // Reminder preferences
  bool _remindersEnabled = true;
  int _reminderDaysBefore = 3;
  bool _updatingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _aiChatEnabled = ConfigService.isAiChatEnabled();
        _simulatorEnabled = ConfigService.isSimulatorEnabled();
        _monthlyPlanEnabled = ConfigService.isMonthlyPlanEnabled();
        _appEnvironment = ConfigService.getAppEnvironment();
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
        _remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
        _reminderDaysBefore = prefs.getInt('reminder_days_before') ?? 3;
      });
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar saída', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Tem certeza que deseja sair da sua conta?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authServiceProvider).signOut();
      if (mounted) context.go('/auth');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDemo = ref.watch(isDemoUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Configurações',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ── Profile ──
          const SettingsSectionHeader('Perfil'),
          const SizedBox(height: 8),
          _buildProfileSection(user, isDemo),

          const SizedBox(height: 24),

          // ── Feature Toggles ──
          const SettingsSectionHeader('Funcionalidades'),
          const SizedBox(height: 8),
          SettingsCard(
            child: Column(
              children: [
                SettingsFeatureRow(icon: Icons.smart_toy_outlined, label: 'Chat com IA', enabled: _aiChatEnabled),
                Divider(color: AppColors.divider, height: 20),
                SettingsFeatureRow(icon: Icons.show_chart, label: 'Simulador', enabled: _simulatorEnabled),
                Divider(color: AppColors.divider, height: 20),
                SettingsFeatureRow(icon: Icons.calendar_month_outlined, label: 'Plano Mensal', enabled: _monthlyPlanEnabled),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Reminders ──
          const SettingsSectionHeader('Lembretes'),
          const SizedBox(height: 8),
          _buildRemindersCard(),

          const SizedBox(height: 24),

          // ── Telegram ──
          const SettingsSectionHeader('Telegram Bot'),
          const SizedBox(height: 8),
          _buildTelegramCard(),

          const SizedBox(height: 24),

          // ── About ──
          const SettingsSectionHeader('Sobre o App'),
          const SizedBox(height: 8),
          SettingsCard(
            child: Column(
              children: [
                SettingsInfoRow(label: 'Versão', value: _appVersion),
                Divider(color: AppColors.divider, height: 20),
                SettingsInfoRow(label: 'Ambiente', value: _appEnvironment.isNotEmpty ? _appEnvironment : '...'),
                Divider(color: AppColors.divider, height: 20),
                SettingsTappableRow(
                  icon: Icons.description_outlined,
                  label: 'Termos de uso',
                  onTap: () => showSettingsInfoDialog(context, 'Termos de Uso', SettingsTexts.terms),
                ),
                Divider(color: AppColors.divider, height: 20),
                SettingsTappableRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Política de privacidade',
                  onTap: () => showSettingsInfoDialog(context, 'Política de Privacidade', SettingsTexts.privacy),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Danger Zone ──
          const SettingsSectionHeader('Zona de perigo', color: AppColors.danger),
          const SizedBox(height: 8),
          SettingsCard(
            borderColor: AppColors.danger.withValues(alpha: 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Encerrar sessão da conta atual.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sair'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Section builders ───

  Widget _buildProfileSection(User? user, bool isDemo) {
    if (user == null || isDemo) {
      return _buildProfileCard(user, UserProfile.empty(user), isDemo);
    }

    return StreamBuilder<UserProfile>(
      stream: UserProfileService.watchProfile(user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data ?? UserProfile.empty(user);
        return _buildProfileCard(user, profile, isDemo);
      },
    );
  }

  Widget _buildProfileCard(User? user, UserProfile profile, bool isDemo) {
    return SettingsCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                backgroundImage: profile.photoUrl.isNotEmpty
                    ? NetworkImage(profile.photoUrl)
                    : null,
                child: profile.photoUrl.isEmpty
                    ? Text(
                        _userInitials(profile.displayName),
                        style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.displayName.isNotEmpty ? profile.displayName : 'Usuário',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isDemo) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Demo', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email.isNotEmpty ? profile.email : (isDemo ? 'Conta anônima' : 'Sem e-mail'),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (profile.occupation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.work_outline_rounded, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            profile.occupation,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                    if (profile.monthlyIncome > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.attach_money_rounded, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'R\$ ${profile.monthlyIncome.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isDemo && user != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _updatingProfile ? null : () => _editProfile(user.uid, profile),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar perfil'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _updatingProfile ? null : () => _pickProfilePhoto(user.uid),
                    icon: _updatingProfile
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_camera_outlined, size: 16),
                    label: const Text('Trocar foto'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRemindersCard() {
    return SettingsCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Lembretes de pagamento', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              ),
              Switch.adaptive(
                value: _remindersEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('reminders_enabled', val);
                  setState(() => _remindersEnabled = val);
                },
              ),
            ],
          ),
          if (_remindersEnabled) ...[
            Divider(color: AppColors.divider, height: 20),
            Row(
              children: [
                const Icon(Icons.schedule_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Dias de antecedência', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                ),
                DropdownButton<int>(
                  value: _reminderDaysBefore,
                  dropdownColor: AppColors.surface,
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                  items: [1, 2, 3, 5, 7]
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d dia${d > 1 ? 's' : ''}')))
                      .toList(),
                  onChanged: (val) async {
                    if (val == null) return;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('reminder_days_before', val);
                    setState(() => _reminderDaysBefore = val);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelegramCard() {
    return FutureBuilder<bool>(
      future: TelegramLinkService.isLinked(),
      builder: (context, snapshot) {
        final isLinked = snapshot.data ?? false;

        return SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.telegram, color: Color(0xFF26A5E4), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Telegram Bot', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          isLinked
                              ? 'Conta vinculada — registre dívidas e gastos por texto ou áudio'
                              : 'Vincule para registrar dívidas por texto ou áudio no Telegram',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Icon(
                      isLinked ? Icons.check_circle_rounded : Icons.link_off_rounded,
                      color: isLinked ? AppColors.success : AppColors.textSecondary,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (isLinked)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Desvincular Telegram?', style: TextStyle(color: AppColors.textPrimary)),
                          content: const Text('Você não poderá mais registrar dívidas pelo Telegram até vincular novamente.', style: TextStyle(color: AppColors.textSecondary)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                              child: const Text('Desvincular'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await TelegramLinkService.unlink();
                        if (mounted) setState(() {});
                      }
                    },
                    icon: const Icon(Icons.link_off_rounded, size: 18),
                    label: const Text('Desvincular'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _generateAndShowTelegramCode(),
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text('Gerar código de vinculação'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF26A5E4),
                      side: const BorderSide(color: Color(0xFF26A5E4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generateAndShowTelegramCode() async {
    final code = await TelegramLinkService.generateLinkCode();
    if (code == null || !mounted) return;
    await Clipboard.setData(ClipboardData(text: '/link $code'));
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Código de vinculação', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                code,
                style: const TextStyle(
                  color: AppColors.primaryContainer,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Passo a passo:',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _telegramStep('1', 'Abra o Telegram e busque @desafog_ai_bot'),
            _telegramStep('2', 'Envie /start para iniciar o bot'),
            _telegramStep('3', 'Envie o comando abaixo:'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: SelectableText(
                '/link $code',
                style: const TextStyle(
                  color: AppColors.primaryContainer,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Comando copiado para a área de transferência!',
              style: TextStyle(color: AppColors.success, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Digite o código EXATAMENTE como mostrado, em MAIÚSCULAS. Ex: $code (e NÃO ${code.toLowerCase()}). O código expira em 15 minutos.',
                      style: const TextStyle(color: AppColors.warning, fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {});
            },
            child: const Text('Fechar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _telegramStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF26A5E4).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(number, style: const TextStyle(color: Color(0xFF26A5E4), fontSize: 11, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }

  String _userInitials(String? displayName) {
    final name = displayName;
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  Future<void> _pickProfilePhoto(String uid) async {
    try {
      setState(() => _updatingProfile = true);
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      await UserProfileService.uploadProfilePhoto(uid: uid, bytes: bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível atualizar a foto: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingProfile = false);
      }
    }
  }

  Future<void> _editProfile(String uid, UserProfile profile) async {
    final nameController = TextEditingController(text: profile.displayName);
    final incomeController = TextEditingController(
      text: profile.monthlyIncome > 0 ? profile.monthlyIncome.toStringAsFixed(2) : '',
    );
    final addressController = TextEditingController(text: profile.address);
    final occupationController = TextEditingController(text: profile.occupation);
    final ageController = TextEditingController(
      text: profile.age != null ? profile.age.toString() : '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar perfil', style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: incomeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Renda mensal (R\$)',
                  prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                  hintText: 'Ex: 3500.00',
                  helperText: 'Usada para calcular plano e simulador',
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: occupationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cargo / Profissão',
                  prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
                  hintText: 'Opcional',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  prefixIcon: Icon(Icons.cake_outlined, size: 20),
                  hintText: 'Opcional',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Endereço / Cidade',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  hintText: 'Opcional',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (saved != true) {
      nameController.dispose();
      incomeController.dispose();
      addressController.dispose();
      occupationController.dispose();
      ageController.dispose();
      return;
    }
    try {
      setState(() => _updatingProfile = true);
      final incomeText = incomeController.text.trim();
      final ageText = ageController.text.trim();
      await UserProfileService.saveProfile(
        uid: uid,
        displayName: nameController.text,
        monthlyIncome: incomeText.isNotEmpty ? double.tryParse(incomeText) : null,
        address: addressController.text,
        occupation: occupationController.text,
        age: ageText.isNotEmpty ? int.tryParse(ageText) : null,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar o perfil: $e')),
      );
    } finally {
      nameController.dispose();
      incomeController.dispose();
      addressController.dispose();
      occupationController.dispose();
      ageController.dispose();
      if (mounted) {
        setState(() => _updatingProfile = false);
      }
    }
  }
}
