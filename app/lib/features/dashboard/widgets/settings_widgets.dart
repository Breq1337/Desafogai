import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Reusable card container for settings sections.
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: child,
    );
  }
}

/// Section header label for settings groups.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader(this.title, {super.key, this.color = AppColors.textSecondary});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// Row showing a label and value side by side.
class SettingsInfoRow extends StatelessWidget {
  const SettingsInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Feature toggle row (icon + label + active/inactive badge).
class SettingsFeatureRow extends StatelessWidget {
  const SettingsFeatureRow({super.key, required this.icon, required this.label, required this.enabled});

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.accent.withValues(alpha: 0.12)
                : AppColors.textSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            enabled ? 'Ativo' : 'Inativo',
            style: TextStyle(
              color: enabled ? AppColors.accent : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tappable row with icon, label, and chevron.
class SettingsTappableRow extends StatelessWidget {
  const SettingsTappableRow({super.key, required this.icon, required this.label, required this.onTap});

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
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}

/// Static legal texts for Terms and Privacy.
abstract final class SettingsTexts {
  static const terms = '''
Ao utilizar o Desafog.ai, você concorda com os seguintes termos:

1. O app fornece sugestões financeiras baseadas nos dados informados por você. Estas sugestões não constituem aconselhamento financeiro profissional.

2. Você é responsável pela precisão dos dados inseridos e pelas decisões financeiras tomadas.

3. O Desafog.ai utiliza inteligência artificial para gerar recomendações (processada em servidores seguros). Os resultados podem variar e não garantem resultados financeiros específicos.

4. Seus dados são armazenados de forma segura via Firebase e não são compartilhados com terceiros.

5. O uso do app é gratuito durante o período beta. Funcionalidades podem mudar sem aviso prévio.
''';

  static const privacy = '''
O Desafog.ai respeita sua privacidade:

- Dados coletados: nome, e-mail (via Google Sign-In), dados de dívidas inseridos por você.

- Armazenamento: Firebase (Google Cloud), com criptografia em trânsito e em repouso.

- IA: Suas perguntas ao chat são enviadas aos servidores Desafog para gerar respostas. Nenhum dado pessoal identificável é incluído nas consultas além do necessário ao contexto financeiro.

- Compartilhamento: Seus dados nunca são vendidos ou compartilhados com terceiros para fins de marketing.

- Exclusão: Você pode solicitar a exclusão de todos os seus dados a qualquer momento nas configurações ou por e-mail.

- Cookies: O app não utiliza cookies de rastreamento.
''';
}

/// Shows a scrollable info dialog (for Terms / Privacy).
void showSettingsInfoDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Text(content, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Fechar', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    ),
  );
}
