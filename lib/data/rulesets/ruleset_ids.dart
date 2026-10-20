enum RulesetId {
  dnd2014('dnd_2014'),
  dnd2024('dnd_2024');

  const RulesetId(this.value);

  final String value;

  static RulesetId parse(Object? value, {bool allowLegacyDefault = false}) {
    if (value == null && allowLegacyDefault) return dnd2014;
    for (final id in values) {
      if (id.value == value) return id;
    }
    throw FormatException('Unsupported rulesetId: $value');
  }
}

enum ContentPackId {
  srd51('srd_5_1', RulesetId.dnd2014),
  srd521('srd_5_2_1', RulesetId.dnd2024);

  const ContentPackId(this.value, this.rulesetId);

  final String value;
  final RulesetId rulesetId;

  static ContentPackId parse(Object? value, {bool allowLegacyDefault = false}) {
    if (value == null && allowLegacyDefault) return srd51;
    for (final id in values) {
      if (id.value == value) return id;
    }
    throw FormatException('Unsupported contentPackId: $value');
  }
}
