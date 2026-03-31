import 'package:desafog_ai/features/dashboard/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('SettingsCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(
        const SettingsCard(child: Text('Hello')),
      ));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders with border color', (tester) async {
      await tester.pumpWidget(_wrap(
        const SettingsCard(
          borderColor: Colors.red,
          child: Text('Bordered'),
        ),
      ));
      expect(find.text('Bordered'), findsOneWidget);
    });
  });

  group('SettingsSectionHeader', () {
    testWidgets('displays uppercased title', (tester) async {
      await tester.pumpWidget(_wrap(
        const SettingsSectionHeader('perfil'),
      ));
      expect(find.text('PERFIL'), findsOneWidget);
    });
  });

  group('SettingsInfoRow', () {
    testWidgets('displays label and value', (tester) async {
      await tester.pumpWidget(_wrap(
        const SettingsInfoRow(label: 'Versão', value: '1.0.0'),
      ));
      expect(find.text('Versão'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });
  });

  group('SettingsFeatureRow', () {
    testWidgets('shows Ativo when enabled', (tester) async {
      await tester.pumpWidget(_wrap(
        const SettingsFeatureRow(
          icon: Icons.smart_toy,
          label: 'Chat IA',
          enabled: true,
        ),
      ));
      expect(find.text('Chat IA'), findsOneWidget);
      expect(find.text('Ativo'), findsOneWidget);
    });

    testWidgets('shows Inativo when disabled', (tester) async {
      await tester.pumpWidget(_wrap(
        const SettingsFeatureRow(
          icon: Icons.smart_toy,
          label: 'Chat IA',
          enabled: false,
        ),
      ));
      expect(find.text('Inativo'), findsOneWidget);
    });
  });

  group('SettingsTappableRow', () {
    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        SettingsTappableRow(
          icon: Icons.description,
          label: 'Termos',
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.text('Termos'));
      expect(tapped, isTrue);
    });

    testWidgets('shows chevron icon', (tester) async {
      await tester.pumpWidget(_wrap(
        SettingsTappableRow(
          icon: Icons.description,
          label: 'Termos',
          onTap: () {},
        ),
      ));
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });
  });

  group('SettingsTexts', () {
    test('terms text is not empty', () {
      expect(SettingsTexts.terms.isNotEmpty, isTrue);
    });

    test('privacy text is not empty', () {
      expect(SettingsTexts.privacy.isNotEmpty, isTrue);
    });
  });

  group('showSettingsInfoDialog', () {
    testWidgets('displays dialog with title and content', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showSettingsInfoDialog(context, 'Test Title', 'Test Content'),
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
    });
  });
}
