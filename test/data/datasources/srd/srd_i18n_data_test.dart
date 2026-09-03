import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _locales = ['de', 'es', 'fr', 'it', 'ja', 'ko', 'pt', 'ru', 'zh'];

Map<String, dynamic> _readJsonMap(String path) {
  return (jsonDecode(File(path).readAsStringSync()) as Map)
      .cast<String, dynamic>();
}

Object? _readJson(String path) => jsonDecode(File(path).readAsStringSync());

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map) return value.cast<String, dynamic>();
  return null;
}

List<dynamic> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}

Set<String> _collectNamedEntries(Object? node) {
  final names = <String>{};

  void visit(Object? value) {
    if (value is List) {
      for (final item in value) {
        visit(item);
      }
      return;
    }
    final map = _asMap(value);
    if (map == null) return;
    final name = map['name'];
    if (name is String && name.trim().isNotEmpty) {
      names.add(name);
    }
    for (final child in map.values) {
      visit(child);
    }
  }

  visit(node);
  return names;
}

Set<String> _collectEntriesWithDescriptions(Object? node) {
  final names = <String>{};

  void visit(Object? value) {
    if (value is List) {
      for (final item in value) {
        visit(item);
      }
      return;
    }
    final map = _asMap(value);
    if (map == null) return;
    final name = map['name'];
    final description = map['description'];
    if (name is String &&
        name.trim().isNotEmpty &&
        description is String &&
        description.trim().isNotEmpty) {
      names.add(name);
    }
    for (final child in map.values) {
      visit(child);
    }
  }

  visit(node);
  return names;
}

void _expectTranslatedField({
  required Map<String, dynamic>? localizedOption,
  required String path,
  required String field,
  required List<String> issues,
}) {
  final value = localizedOption?[field];
  if (value is String && value.trim().isNotEmpty) return;
  issues.add('$path.$field');
}

void _checkFeatureChoiceOptions({
  required Map<String, dynamic> srd,
  required Map<String, dynamic> localized,
  required List<String> issues,
}) {
  final srdSources = _asMap(srd['optionSources']) ?? const {};
  final localizedSources = _asMap(localized['optionSources']) ?? const {};

  for (final sourceEntry in srdSources.entries) {
    final sourceId = sourceEntry.key;
    final localizedSource = _asMap(localizedSources[sourceId]);
    for (final option in _asList(sourceEntry.value)) {
      final optionMap = _asMap(option);
      final optionId = optionMap?['id'] as String?;
      if (optionId == null || optionId.isEmpty) continue;
      final path = 'optionSources.$sourceId.$optionId';
      final localizedOption = _asMap(localizedSource?[optionId]);
      _expectTranslatedField(
        localizedOption: localizedOption,
        path: path,
        field: 'name',
        issues: issues,
      );
      _expectTranslatedField(
        localizedOption: localizedOption,
        path: path,
        field: 'description',
        issues: issues,
      );
    }
  }
}

void _checkFeatureChoiceDefinitions({
  required Map<String, dynamic>? srdNode,
  required Map<String, dynamic>? localizedNode,
  required List<String> path,
  required List<String> issues,
}) {
  if (srdNode == null) return;

  for (final entry in srdNode.entries) {
    final srdValue = _asMap(entry.value);
    if (srdValue == null) continue;
    final localizedValue = _asMap(localizedNode?[entry.key]);
    final choices = _asList(srdValue['choices']);

    if (choices.isNotEmpty) {
      final localizedChoices = _asMap(localizedValue?['choices']);
      for (final choice in choices) {
        final choiceMap = _asMap(choice);
        final choiceId = choiceMap?['id'] as String?;
        if (choiceId == null || choiceId.isEmpty) continue;
        final localizedChoice = _asMap(localizedChoices?[choiceId]);
        final localizedOptions = _asMap(localizedChoice?['options']);

        for (final option in _asList(choiceMap?['options'])) {
          final optionMap = _asMap(option);
          final optionId = optionMap?['id'] as String?;
          if (optionId == null || optionId.isEmpty) continue;
          final optionPath = [
            ...path,
            entry.key,
            'choices',
            choiceId,
            'options',
            optionId,
          ].join('.');
          final localizedOption = _asMap(localizedOptions?[optionId]);
          _expectTranslatedField(
            localizedOption: localizedOption,
            path: optionPath,
            field: 'name',
            issues: issues,
          );
          final sourceDescription = optionMap?['description'];
          if (sourceDescription is String &&
              sourceDescription.trim().isNotEmpty) {
            _expectTranslatedField(
              localizedOption: localizedOption,
              path: optionPath,
              field: 'description',
              issues: issues,
            );
          }
        }
      }
      continue;
    }

    _checkFeatureChoiceDefinitions(
      srdNode: srdValue,
      localizedNode: localizedValue,
      path: [...path, entry.key],
      issues: issues,
    );
  }
}

void main() {
  group('SRD i18n data', () {
    for (final locale in _locales) {
      test('$locale has names for critical SRD lookup entries', () {
        for (final fileName in ['skills', 'tools', 'equipment', 'spells']) {
          final srd = _readJson('assets/data/srd/$fileName.json');
          final localized = _readJsonMap(
            'assets/data/i18n/$locale/$fileName.json',
          );
          final missing = _collectNamedEntries(srd).where((name) {
            final entry = _asMap(localized[name]);
            final translatedName = entry?['name'];
            return translatedName is! String || translatedName.trim().isEmpty;
          }).toList();

          expect(
            missing,
            isEmpty,
            reason:
                'assets/data/i18n/$locale/$fileName.json is missing names: '
                '${missing.join(', ')}',
          );
        }
      });

      test('$locale has descriptions for SRD spells and equipment', () {
        for (final fileName in ['equipment', 'spells']) {
          final srd = _readJson('assets/data/srd/$fileName.json');
          final localized = _readJsonMap(
            'assets/data/i18n/$locale/$fileName.json',
          );
          final missing = _collectEntriesWithDescriptions(srd).where((name) {
            final entry = _asMap(localized[name]);
            final description = entry?['description'];
            return description is! String || description.trim().isEmpty;
          }).toList();

          expect(
            missing,
            isEmpty,
            reason:
                'assets/data/i18n/$locale/$fileName.json is missing '
                'descriptions: ${missing.join(', ')}',
          );
        }
      });

      test('$locale has feature choice option names and descriptions', () {
        final srd = _readJsonMap('assets/data/srd/feature_choices.json');
        final localized = _readJsonMap(
          'assets/data/i18n/$locale/feature_choices.json',
        );
        final issues = <String>[];

        _checkFeatureChoiceOptions(
          srd: srd,
          localized: localized,
          issues: issues,
        );
        for (final root in [
          'classFeatures',
          'subclassFeatures',
          'raceTraits',
          'feats',
        ]) {
          _checkFeatureChoiceDefinitions(
            srdNode: _asMap(srd[root]),
            localizedNode: _asMap(localized[root]),
            path: [root],
            issues: issues,
          );
        }

        expect(
          issues,
          isEmpty,
          reason:
              'assets/data/i18n/$locale/feature_choices.json is missing: '
              '${issues.join(', ')}',
        );
      });
    }
  });
}
