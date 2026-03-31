import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/config_service.dart';
import '../../../core/services/telegram_link_service.dart';
import '../../../core/services/token_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _updatingProfile = false;
  bool _remindersEnabled = true;
  int _reminderDaysBefore = 3;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final pkg = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
        _reminderDaysBefore = prefs.getInt('reminder_days_before') ?? 3;
        _appVersion = '${pkg.version}+${pkg.buildNumber}';
      });
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Tem certeza que deseja encerrar sua sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
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
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              'Perfil',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            _buildProfileHeader(user, textTheme),
            const SizedBox(height: 28),

            const SectionHeader(title: 'Notificações'),
            _buildNotificationsCard(textTheme),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Integração'),
            _buildTelegramCard(textTheme),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Tokens de API'),
            const _TokensSection(),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Sobre'),
            PremiumCard(
              child: Column(
                children: [
                  _InfoRow(label: 'Versão', value: _appVersion.isNotEmpty ? _appVersion : '...'),
                  Divider(color: AppColors.divider, height: 20),
                  _TappableRow(
                    icon: Icons.description_outlined,
                    label: 'Termos de uso',
                    onTap: () {},
                  ),
                  Divider(color: AppColors.divider, height: 20),
                  _TappableRow(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Política de privacidade',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sair da conta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user, TextTheme textTheme) {
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<UserProfile>(
      stream: UserProfileService.watchProfile(user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data ?? UserProfile.empty(user);

        return PremiumCard(
          padding: AppSpacing.cardPaddingLarge,
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _updatingProfile ? null : () => _pickPhoto(user.uid),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.12),
                      backgroundImage: profile.photoUrl.isNotEmpty
                          ? NetworkImage(profile.photoUrl)
                          : null,
                      child: profile.photoUrl.isEmpty
                          ? Text(
                              _initials(profile.displayName),
                              style: const TextStyle(
                                color: AppColors.primaryContainer,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName.isNotEmpty ? profile.displayName : 'Usuário',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (profile.email.isNotEmpty)
                          Text(
                            profile.email,
                            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        if (profile.monthlyIncome > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Renda: R\$ ${profile.monthlyIncome.toStringAsFixed(0)}/mês',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _updatingProfile ? null : () => _editProfile(user.uid, profile),
                  child: _updatingProfile
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Editar perfil'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsCard(TextTheme textTheme) {
    return PremiumCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Lembretes de pagamento', style: textTheme.bodyMedium),
              ),
              Switch.adaptive(
                value: _remindersEnabled,
                activeTrackColor: AppColors.primaryContainer,
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
                Expanded(child: Text('Antecedência', style: textTheme.bodyMedium)),
                DropdownButton<int>(
                  value: _reminderDaysBefore,
                  dropdownColor: AppColors.surface,
                  underline: const SizedBox.shrink(),
                  style: TextStyle(
                    color: AppColors.primaryContainer,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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

  Widget _buildTelegramCard(TextTheme textTheme) {
    return FutureBuilder<bool>(
      future: TelegramLinkService.isLinked(),
      builder: (context, snapshot) {
        final isLinked = snapshot.data ?? false;

        return PremiumCard(
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
                        Text('Telegram', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          isLinked
                              ? 'Conectado — registre gastos por texto ou áudio'
                              : 'Vincule para registrar gastos pelo Telegram',
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isLinked ? AppColors.success : AppColors.textTertiary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isLinked ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isLinked ? AppColors.success : AppColors.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLinked
                      ? () => _unlinkTelegram()
                      : () => _generateTelegramCode(),
                  style: isLinked
                      ? OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                        )
                      : OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF26A5E4),
                          side: const BorderSide(color: Color(0xFF26A5E4)),
                        ),
                  child: Text(isLinked ? 'Desvincular' : 'Vincular Telegram'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _unlinkTelegram() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desvincular Telegram?'),
        content: const Text('Você não poderá registrar gastos pelo Telegram até vincular novamente.'),
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
  }

  Future<void> _generateTelegramCode() async {
    final code = await TelegramLinkService.generateLinkCode();
    if (code == null || !mounted) return;
    await Clipboard.setData(ClipboardData(text: '/link $code'));
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vincular Telegram'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: SelectableText(
                '/link $code',
                style: const TextStyle(
                  color: AppColors.primaryContainer,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comando copiado. Envie no @desafog_ai_bot no Telegram.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'O código expira em 15 minutos.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {});
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return parts.first[0].toUpperCase();
  }

  Future<void> _pickPhoto(String uid) async {
    try {
      setState(() => _updatingProfile = true);
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1024);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      await UserProfileService.uploadProfilePhoto(uid: uid, bytes: bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar foto: $e')),
      );
    } finally {
      if (mounted) setState(() => _updatingProfile = false);
    }
  }

  Future<void> _editProfile(String uid, UserProfile profile) async {
    final nameCtl = TextEditingController(text: profile.displayName);
    final incomeCtl = TextEditingController(
      text: profile.monthlyIncome > 0 ? profile.monthlyIncome.toStringAsFixed(0) : '',
    );
    final occupationCtl = TextEditingController(text: profile.occupation);
    final addressCtl = TextEditingController(text: profile.address);
    final ageCtl = TextEditingController(text: profile.age != null ? profile.age.toString() : '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Editar perfil', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline, size: 20))),
            const SizedBox(height: 12),
            TextField(controller: incomeCtl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Renda mensal (R\$)', prefixIcon: Icon(Icons.attach_money, size: 20))),
            const SizedBox(height: 12),
            TextField(controller: occupationCtl, decoration: const InputDecoration(labelText: 'Profissão', prefixIcon: Icon(Icons.work_outline, size: 20))),
            const SizedBox(height: 12),
            TextField(controller: ageCtl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Idade', prefixIcon: Icon(Icons.cake_outlined, size: 20))),
            const SizedBox(height: 12),
            TextField(controller: addressCtl, decoration: const InputDecoration(labelText: 'Cidade', prefixIcon: Icon(Icons.location_on_outlined, size: 20))),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Salvar'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (saved != true) {
      nameCtl.dispose(); incomeCtl.dispose(); occupationCtl.dispose();
      addressCtl.dispose(); ageCtl.dispose();
      return;
    }

    try {
      setState(() => _updatingProfile = true);
      await UserProfileService.saveProfile(
        uid: uid,
        displayName: nameCtl.text,
        monthlyIncome: double.tryParse(incomeCtl.text.trim()),
        address: addressCtl.text,
        occupation: occupationCtl.text,
        age: int.tryParse(ageCtl.text.trim()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      nameCtl.dispose(); incomeCtl.dispose(); occupationCtl.dispose();
      addressCtl.dispose(); ageCtl.dispose();
      if (mounted) setState(() => _updatingProfile = false);
    }
  }
}

class _TokensSection extends StatefulWidget {
  const _TokensSection();

  @override
  State<_TokensSection> createState() => _TokensSectionState();
}

class _TokensSectionState extends State<_TokensSection> {
  final _tokenService = TokenService();
  List<TokenMeta>? _tokens;
  bool _loading = true;
  String? _error;
  String? _newTokenValue;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tokens = await _tokenService.listTokens();
      if (mounted) setState(() { _tokens = tokens; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _createToken() async {
    try {
      final result = await _tokenService.createToken();
      setState(() => _newTokenValue = result.rawToken);
      _loadTokens();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _revokeToken(String tokenId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revogar token?'),
        content: const Text('Esse token será desativado permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _tokenService.revokeToken(tokenId);
      _loadTokens();
    }
  }

  Future<void> _regenerateToken(String tokenId) async {
    try {
      final result = await _tokenService.regenerateToken(tokenId);
      setState(() => _newTokenValue = result.rawToken);
      _loadTokens();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return const PremiumCard(
        child: Center(child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        )),
      );
    }

    if (_error != null) {
      return PremiumCard(
        child: Text(
          'Não foi possível carregar tokens.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final activeTokens = (_tokens ?? []).where((t) => t.isActive).toList();
    final revokedTokens = (_tokens ?? []).where((t) => !t.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_newTokenValue != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Token criado — copie agora:', style: textTheme.bodySmall?.copyWith(color: AppColors.success)),
                const SizedBox(height: 6),
                SelectableText(
                  _newTokenValue!,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Esse valor não será exibido novamente.',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        ...activeTokens.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PremiumCard(
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t.prefix}...',
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                          ),
                          if (t.lastUsedAt != null)
                            Text(
                              'Último uso: ${_formatDate(t.lastUsedAt!)}',
                              style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary, fontSize: 11),
                            )
                          else
                            Text(
                              'Nunca usado',
                              style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'regenerate', child: Text('Regenerar')),
                        const PopupMenuItem(value: 'revoke', child: Text('Revogar')),
                      ],
                      onSelected: (action) {
                        if (action == 'revoke') _revokeToken(t.id);
                        if (action == 'regenerate') _regenerateToken(t.id);
                      },
                      icon: Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )),

        if (activeTokens.length < 3)
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _createToken,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Criar token'),
            ),
          ),

        if (revokedTokens.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${revokedTokens.length} token${revokedTokens.length > 1 ? 's' : ''} revogado${revokedTokens.length > 1 ? 's' : ''}',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _TappableRow extends StatelessWidget {
  const _TappableRow({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
        ],
      ),
    );
  }
}
