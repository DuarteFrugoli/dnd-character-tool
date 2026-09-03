import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/features/character_detail/widgets/feature_choice_display_helpers.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String?> _localizedSubtitle(
  WidgetTester tester, {
  required Locale locale,
  required FeatureChoiceRequest request,
  required SrdFeatureChoiceOption option,
}) async {
  String? subtitle;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          subtitle = featureChoiceOptionSubtitle(
            context: context,
            request: request,
            option: option,
            i18n: SrdI18nService.english,
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return subtitle;
}

void main() {
  group('featureChoiceOptionSubtitle', () {
    testWidgets('localizes skill ability subtitles', (tester) async {
      const request = FeatureChoiceRequest(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: 'Rogue',
        featureName: 'Expertise',
        level: 1,
        requirement: SrdFeatureChoiceRequirement(
          id: 'expertise',
          type: 'skill_expertise',
          count: 2,
        ),
        requiredCount: 2,
      );

      final subtitle = await _localizedSubtitle(
        tester,
        locale: const Locale('pt'),
        request: request,
        option: const SrdFeatureChoiceOption(
          id: 'acrobatics',
          name: 'Acrobacia',
          description: 'DEXTERITY',
        ),
      );

      expect(subtitle, 'Destreza');
    });

    testWidgets('humanizes tool categories instead of showing snake case', (
      tester,
    ) async {
      const request = FeatureChoiceRequest(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: 'Rogue',
        featureName: 'Expertise',
        level: 1,
        requirement: SrdFeatureChoiceRequirement(
          id: 'expertise',
          type: 'skill_or_tool_expertise',
          count: 2,
          allowThievesTools: true,
        ),
        requiredCount: 2,
      );

      final subtitle = await _localizedSubtitle(
        tester,
        locale: const Locale('en'),
        request: request,
        option: const SrdFeatureChoiceOption(
          id: 'tool:thieves_tools',
          name: "Thieves' tools",
          description: 'other_tools',
        ),
      );

      expect(subtitle, 'Other Tools');
      expect(subtitle, isNot(contains('_')));
    });
  });
}
