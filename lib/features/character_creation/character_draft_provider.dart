import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/constants/armor_class.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';

// ── Estado do rascunho ────────────────────────────────────────────────────────

enum AttributeMethod { standardArray, pointBuy, rolledDice }

// ── Equipment type detection ──────────────────────────────────────────────────

const _kWeaponKeywords = [
  'sword', 'axe', 'bow', 'crossbow', 'dagger', 'mace', 'hammer', 'spear',
  'javelin', 'lance', 'rapier', 'scimitar', 'halberd', 'glaive', 'pike',
  'flail', 'maul', 'quarterstaff', 'staff', 'sickle', 'club', 'trident',
  'handaxe', 'greataxe', 'warhammer', 'morningstar', 'war pick', 'whip',
  'blowgun', 'sling', 'dart', 'net',
];

const _kArmorKeywords = [
  'chain mail', 'chain shirt', 'scale mail', 'ring mail', 'leather armor',
  'studded leather', 'padded armor', 'hide armor', 'breastplate',
  'half plate', 'plate armor', 'splint', 'leather', 'padded',
  'hide', 'plate',
];

const _kAmmoKeywords = ['arrows', 'bolts', 'darts', 'needles'];

/// Returns the appropriate [ItemType] for an equipment item name.
ItemType _itemTypeForItem(String name) {
  final lower = name.toLowerCase();
  // Check shield first — it IS armor
  if (lower.contains('shield')) return ItemType.armor;
  for (final kw in _kArmorKeywords) {
    if (lower.contains(kw)) return ItemType.armor;
  }
  for (final kw in _kAmmoKeywords) {
    if (lower.contains(kw)) return ItemType.ammunition;
  }
  for (final kw in _kWeaponKeywords) {
    if (lower.contains(kw)) return ItemType.weapon;
  }
  return ItemType.gear;
}

/// Returns a human-readable category string for the character sheet.
String _categoryForItem(String name) {
  switch (_itemTypeForItem(name)) {
    case ItemType.weapon:
      return 'weapon';
    case ItemType.armor:
      return 'armor';
    case ItemType.ammunition:
      return 'ammunition';
    default:
      return 'adventuring gear';
  }
}

/// Returns extra [EquipmentItem.properties] for armor/shield items.
Map<String, dynamic>? _propertiesForItem(String name) {
  final lower = name.toLowerCase();
  if (_itemTypeForItem(name) != ItemType.armor) return null;

  // Shield
  if (lower.contains('shield')) return {'isShield': true, 'acBonus': 2};

  // Armor table: (pattern, baseAC, addDexModifier, maxDexBonus or null=unlimited)
  const armorTable = <(String, int, bool, int?)>[
    ('half plate',      15, true,  2),
    ('studded leather', 12, true,  null),
    ('chain mail',      16, false, null),
    ('ring mail',       14, false, null),
    ('scale mail',      14, true,  2),
    ('chain shirt',     13, true,  2),
    ('plate',           18, false, null),
    ('splint',          17, false, null),
    ('breastplate',     14, true,  2),
    ('hide',            12, true,  2),
    ('leather',         11, true,  null),
    ('padded',          11, true,  null),
  ];
  for (final (pattern, base, addDex, maxDex) in armorTable) {
    if (lower.contains(pattern)) {
      return {
        'baseAC': base,
        'addDexModifier': addDex,
        'maxDexBonus': ?maxDex,
      };
    }
  }
  return null;
}

/// Returns true when the equipment string represents a player choice
/// rather than a fixed item (e.g. "Musical instrument", "Artisan's tools").
bool isEquipmentChoiceItem(String item) {
  final lower = item.toLowerCase();
  return lower.contains('musical instrument') ||
      lower.contains("artisan's tools") ||
      lower.contains('gaming set') ||
      lower.contains('tools of the con');
}

class CharacterDraft {
  final String id;
  final SrdClass? selectedClass;
  final SrdSubclass? selectedSubclass;
  final SrdRace? selectedRace;
  final SrdSubrace? selectedSubrace;
  final SrdBackground? selectedBackground;
  // Perícias escolhidas pelo usuário (classe + raça opcional)
  final List<String> chosenSkills;
  // Mapa atributo → valor base (antes dos bônus raciais)
  final Map<String, int> baseAttributes;
  final AttributeMethod attributeMethod;
  final bool freeAsi; // true = Tasha's (distribuir ASI livremente)
  // Se freeAsi, mapa de distribuição manual dos ASI points
  final Map<String, int> freeAsiDistribution;
  // Pontos ASI livres da raça (ex: Half-Elf twoOthers) — sempre obrigatório
  final Map<String, int> freePicksDistribution;
  final String name;
  final String playerName;
  // Itens do background que o usuário quer adicionar ao inventário
  final List<String> selectedStartingEquipment;
  // Idiomas escolhidos livremente pelo usuário (raça "any" + background)
  final List<String> chosenLanguages;
  // Ferramentas escolhidas livremente (raça + background + classe)
  final List<String> chosenToolProficiencies;
  // Valores rolados no modo 4d6 drop lowest (6 valores)
  final List<int> rolledValues;
  // Escolhas de equipamento inicial de classe:
  // índice da opção escolhida em cada grupo de escolha
  final List<int?> classEquipmentChoices;
  // Sub-escolhas para itens "any X" dentro da opção escolhida
  // chave: "$grupoIdx:$itemIdx" → nome específico do item
  final Map<String, String> classEquipmentSpecifics;
  // Itens de equipamento com escolha: chave = nome genérico, valor = item escolhido
  // Ex: "Musical instrument" → "Flute"
  final Map<String, String> resolvedEquipmentChoices;
  // Resultado da rolagem de ouro inicial (null = não rolado ainda)
  final int? rolledStartingGold;

  const CharacterDraft({
    required this.id,
    this.selectedClass,
    this.selectedSubclass,
    this.selectedRace,
    this.selectedSubrace,
    this.selectedBackground,
    this.chosenSkills = const [],
    this.baseAttributes = const {},
    this.attributeMethod = AttributeMethod.standardArray,
    this.freeAsi = false,
    this.freeAsiDistribution = const {},
    this.freePicksDistribution = const {},
    this.name = '',
    this.playerName = '',
    this.selectedStartingEquipment = const [],
    this.chosenLanguages = const [],
    this.chosenToolProficiencies = const [],
    this.rolledValues = const [],
    this.resolvedEquipmentChoices = const {},
    this.classEquipmentChoices = const [],
    this.classEquipmentSpecifics = const {},
    this.rolledStartingGold,
  });

  CharacterDraft copyWith({
    Object? selectedClass = _sentinel,
    Object? selectedSubclass = _sentinel,
    Object? selectedRace = _sentinel,
    Object? selectedSubrace = _sentinel,
    SrdBackground? selectedBackground,
    List<String>? chosenSkills,
    Map<String, int>? baseAttributes,
    AttributeMethod? attributeMethod,
    bool? freeAsi,
    Map<String, int>? freeAsiDistribution,
    Map<String, int>? freePicksDistribution,
    String? name,
    String? playerName,
    List<String>? selectedStartingEquipment,
    List<String>? chosenLanguages,
    List<String>? chosenToolProficiencies,
    List<int>? rolledValues,
    Map<String, String>? resolvedEquipmentChoices,
    List<int?>? classEquipmentChoices,
    Map<String, String>? classEquipmentSpecifics,
    Object? rolledStartingGold = _sentinel,
  }) {
    return CharacterDraft(
      id: id,
      selectedClass: selectedClass == _sentinel
          ? this.selectedClass
          : selectedClass as SrdClass?,
      selectedSubclass: selectedSubclass == _sentinel
          ? this.selectedSubclass
          : selectedSubclass as SrdSubclass?,
      selectedRace: selectedRace == _sentinel
          ? this.selectedRace
          : selectedRace as SrdRace?,
      selectedSubrace: selectedSubrace == _sentinel
          ? this.selectedSubrace
          : selectedSubrace as SrdSubrace?,
      selectedBackground: selectedBackground ?? this.selectedBackground,
      chosenSkills: chosenSkills ?? this.chosenSkills,
      baseAttributes: baseAttributes ?? this.baseAttributes,
      attributeMethod: attributeMethod ?? this.attributeMethod,
      freeAsi: freeAsi ?? this.freeAsi,
      freeAsiDistribution: freeAsiDistribution ?? this.freeAsiDistribution,
      freePicksDistribution: freePicksDistribution ?? this.freePicksDistribution,
      name: name ?? this.name,
      playerName: playerName ?? this.playerName,
      selectedStartingEquipment:
          selectedStartingEquipment ?? this.selectedStartingEquipment,
      chosenLanguages: chosenLanguages ?? this.chosenLanguages,
      chosenToolProficiencies:
          chosenToolProficiencies ?? this.chosenToolProficiencies,
      rolledValues: rolledValues ?? this.rolledValues,
      resolvedEquipmentChoices:
          resolvedEquipmentChoices ?? this.resolvedEquipmentChoices,      classEquipmentChoices:
          classEquipmentChoices ?? this.classEquipmentChoices,
      classEquipmentSpecifics:
          classEquipmentSpecifics ?? this.classEquipmentSpecifics,
      rolledStartingGold: rolledStartingGold == _sentinel
          ? this.rolledStartingGold
          : rolledStartingGold as int?,
    );
  }

  // Retorna os atributos finais com bônus raciais aplicados
  Map<String, int> get finalAttributes {
    final result = Map<String, int>.from(baseAttributes);
    if (freeAsi) {
      // Distribuição livre: aplica o que o usuário escolheu
      freeAsiDistribution.forEach((attr, bonus) {
        result[attr] = (result[attr] ?? 8) + bonus;
      });
    } else {
      // Combina bônus da raça base + subraça
      final raceAsi = selectedRace?.abilityScoreIncreases ?? {};
      final subraceAsi = selectedSubrace?.abilityScoreIncreases ?? {};
      final mergedAsi = <String, int>{...raceAsi};
      subraceAsi.forEach((attr, bonus) {
        mergedAsi[attr] = (mergedAsi[attr] ?? 0) + bonus;
      });
      mergedAsi.forEach((attr, bonus) {
        result[attr] = (result[attr] ?? 8) + bonus;
      });
    }
    // Pontos livres da raça (twoOthers, etc.) — sempre aplicados
    freePicksDistribution.forEach((attr, bonus) {
      result[attr] = (result[attr] ?? 8) + bonus;
    });
    return result;
  }

  // Todas as perícias garantidas (background + raça fixa)
  List<String> get grantedSkills {
    final skills = <String>[];
    if (selectedBackground != null) {
      skills.addAll(selectedBackground!.skillProficiencies);
    }
    // Elfo tem Percepção garantida, por exemplo — está nos traits, não num campo
    // separado no JSON, por ora ignoramos perícias de raça automáticas.
    return skills;
  }

  /// Idiomas fixos da raça (exclui entradas "one extra of your choice").
  List<String> get fixedRaceLanguages =>
      selectedRace?.languages
          .where((l) => !l.toLowerCase().contains('of your choice'))
          .toList() ??
      [];

  /// Quantidade total de idiomas que o jogador precisa escolher livremente.
  int get languageChoicesNeeded {
    final raceChoices = selectedRace?.languages
            .where((l) => l.toLowerCase().contains('of your choice'))
            .length ??
        0;
    final bgChoices = selectedBackground?.languages ?? 0;
    return raceChoices + bgChoices;
  }

  int get equipmentChoicesNeeded =>
      selectedBackground?.startingEquipment
          .where(isEquipmentChoiceItem)
          .length ??
      0;

  /// True when every class equipment choice group has a selection
  /// and all "any X" sub-picks within the selected options are filled.
  bool get classEquipmentComplete {
    final equip = selectedClass?.startingEquipment;
    if (equip == null) return true;
    for (int g = 0; g < equip.choices.length; g++) {
      if (g >= classEquipmentChoices.length) return false;
      final optIdx = classEquipmentChoices[g];
      if (optIdx == null) return false;
      final option = equip.choices[g].options[optIdx];
      for (int i = 0; i < option.length; i++) {
        if (option[i].toLowerCase().startsWith('any ') &&
            classEquipmentSpecifics['$g:$i'] == null) {
          return false;
        }
      }
    }
    return true;
  }

  int get toolChoicesNeeded {
    int count = 0;
    bool isChoice(String tool) {
      final lower = tool.toLowerCase();
      return lower.contains('one type of') || lower.contains('of your choice');
    }
    // Race: Tool Proficiency trait -> one artisan's tool
    if (selectedRace != null &&
        selectedRace!.traits.contains('Tool Proficiency')) {
      count += 1;
    }
    // Background tool choices
    if (selectedBackground != null) {
      for (final tool in selectedBackground!.toolProficiencies) {
        if (isChoice(tool)) count++;
      }
    }
    // Class tool choices
    if (selectedClass != null) {
      for (final tool in selectedClass!.toolProficiencies) {
        if (isChoice(tool)) {
          final lower = tool.toLowerCase();
          final match =
              RegExp(r'(\w+) musical instrument').firstMatch(lower);
          final countWord = match?.group(1);
          count += const {
                'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
              }[countWord] ??
              1;
        }
      }
    }
    return count;
  }

  // Verifica se o rascunho tem o mínimo para ser salvo
  bool get isComplete {
    if (selectedClass == null || selectedRace == null ||
        selectedBackground == null || baseAttributes.length != 6) {
      return false;
    }
    // Se a raça tem pontos livres (ex: Half-Elf), todos precisam ser distribuídos
    final freeNeeded = selectedRace!.freeAsiPoints;
    if (freeNeeded > 0) {
      final assigned = freePicksDistribution.values.fold(0, (a, b) => a + b);
      if (assigned != freeNeeded) return false;
    }
    // Idiomas livres precisam ser escolhidos
    if (chosenLanguages.length < languageChoicesNeeded) return false;
    return true;
  }
}

// Sentinel para distinguir null intencional de "não passado"
const _sentinel = Object();

// ── Notifier ──────────────────────────────────────────────────────────────────

class CharacterDraftNotifier extends Notifier<CharacterDraft> {
  @override
  CharacterDraft build() => CharacterDraft(id: const Uuid().v4());

  void reset() => state = CharacterDraft(id: const Uuid().v4());

  void setClass(SrdClass c) => state = state.copyWith(
        selectedClass: c,
        selectedSubclass: null,
        chosenSkills: [],
        chosenToolProficiencies: [],
        classEquipmentChoices: [],
        classEquipmentSpecifics: {},
      );

  void clearClass() => state = state.copyWith(
        selectedClass: null,
        selectedSubclass: null,
        chosenSkills: [],
        chosenToolProficiencies: [],
        classEquipmentChoices: [],
        classEquipmentSpecifics: {},
      );

  void setSubclass(SrdSubclass? s) =>
      state = state.copyWith(selectedSubclass: s);

  void setRace(SrdRace r) => state = state.copyWith(
        selectedRace: r,
        selectedSubrace: null,
        freePicksDistribution: {},
        chosenLanguages: [],
        chosenToolProficiencies: [],
      );

  void clearRace() => state = state.copyWith(
        selectedRace: null,
        selectedSubrace: null,
        freePicksDistribution: {},
        chosenLanguages: [],
        chosenToolProficiencies: [],
      );

  void setSubrace(SrdSubrace? s) =>
      state = state.copyWith(selectedSubrace: s);

  void setBackground(SrdBackground b) => state = state.copyWith(
        selectedBackground: b,
        // Pré-seleciona apenas itens fixos (escolhas ficam no resolvedEquipmentChoices)
        selectedStartingEquipment: b.startingEquipment
            .where((i) => !isEquipmentChoiceItem(i))
            .toList(),
        // Reseta idiomas, ferramentas e escolhas de equipamento ao trocar background
        chosenLanguages: [],
        chosenToolProficiencies: [],
        resolvedEquipmentChoices: {},
      );

  void toggleStartingItem(String item) {
    final current = List<String>.from(state.selectedStartingEquipment);
    if (current.contains(item)) {
      current.remove(item);
    } else {
      current.add(item);
    }
    state = state.copyWith(selectedStartingEquipment: current);
  }

  void setChosenSkills(List<String> skills) =>
      state = state.copyWith(chosenSkills: skills);

  void setBaseAttributes(Map<String, int> attrs) =>
      state = state.copyWith(baseAttributes: attrs);

  void setAttributeMethod(AttributeMethod m) =>
      state = state.copyWith(attributeMethod: m);

  void setRolledValues(List<int> values) =>
      state = state.copyWith(rolledValues: values);

  void setFreeAsi(bool v) => state = state.copyWith(freeAsi: v);

  void setFreeAsiDistribution(Map<String, int> dist) =>
      state = state.copyWith(freeAsiDistribution: dist);

  void setFreePicksDistribution(Map<String, int> dist) =>
      state = state.copyWith(freePicksDistribution: dist);

  void setName(String n) => state = state.copyWith(name: n);
  void setPlayerName(String n) => state = state.copyWith(playerName: n);
  void setChosenLanguages(List<String> langs) =>
      state = state.copyWith(chosenLanguages: langs);

  void setChosenToolProficiencies(List<String> tools) =>
      state = state.copyWith(chosenToolProficiencies: tools);

  void setRolledStartingGold(int? gp) =>
      state = state.copyWith(rolledStartingGold: gp ?? _sentinel);

  void setEquipmentChoice(String generic, String specific) {
    final updated = Map<String, String>.from(state.resolvedEquipmentChoices)
      ..[generic] = specific;
    state = state.copyWith(resolvedEquipmentChoices: updated);
  }

  void setClassEquipmentChoice(int groupIdx, int optionIdx) {
    final choices = List<int?>.from(state.classEquipmentChoices);
    while (choices.length <= groupIdx) {
      choices.add(null);
    }
    choices[groupIdx] = optionIdx;
    // Clear sub-picks for this group since option changed
    final specifics =
        Map<String, String>.from(state.classEquipmentSpecifics)
          ..removeWhere((k, _) => k.startsWith('$groupIdx:'));
    state = state.copyWith(
      classEquipmentChoices: choices,
      classEquipmentSpecifics: specifics,
    );
  }

  void setClassEquipmentSpecific(String key, String value) {
    final specifics =
        Map<String, String>.from(state.classEquipmentSpecifics)..[key] = value;
    state = state.copyWith(classEquipmentSpecifics: specifics);
  }

  Future<Character> buildAndSave(WidgetRef ref, {String fallbackName = 'Unnamed Hero'}) async {
    final draft = state;
    final repo = ref.read(characterRepositoryProvider);
    final attrs = draft.finalAttributes;

    final con = attrs['Constitution'] ?? 10;
    final conMod = ((con - 10) / 2).floor();
    final hitDie = draft.selectedClass!.hitDie;

    // Converte itens de background selecionados em EquipmentItems
    // Itens no formato "X gp" viram currency, os outros recebem o tipo correto
    final gpPattern = RegExp(r'^(\d+)\s*gp$', caseSensitive: false);
    final startingEquipment = <EquipmentItem>[];
    // Start with the rolled class gold (if the player rolled)
    int startingGp = draft.rolledStartingGold ?? 0;

    // Load the SRD items lookup table for accurate type/category/properties.
    // Falls back to keyword heuristic for unknown items.
    final itemsDb = await ref.read(srdItemsProvider.future);

    SrdItemData? lookupItem(String name) {
      final lower = name.toLowerCase();
      // Try exact match first, then try without trailing 's' for plurals
      return itemsDb[lower] ??
          (lower.endsWith('s')
              ? itemsDb[lower.substring(0, lower.length - 1)]
              : null);
    }

    void addItem(String raw) {
      final trimmed = raw.trim();

      // Check if the full string is a gold amount (e.g. "15 gp") before
      // attempting quantity parsing, otherwise "15 gp" → qty=15, name="gp".
      final rawGpMatch = gpPattern.firstMatch(trimmed);
      if (rawGpMatch != null) {
        startingGp += int.parse(rawGpMatch.group(1)!);
        return;
      }

      // Handle "N x Item" patterns (e.g. "20 arrows", "4 javelins")
      final match = RegExp(r'^(\d+)\s+(.+)$').firstMatch(trimmed);
      final qty = match != null ? int.parse(match.group(1)!) : 1;
      final itemName = match != null ? match.group(2)! : trimmed;

      final gpMatch = gpPattern.firstMatch(itemName);
      if (gpMatch != null) {
        startingGp += qty * int.parse(gpMatch.group(1)!);
        return;
      }

      final data = lookupItem(itemName);
      startingEquipment.add(EquipmentItem(
        name: itemName,
        category: data?.category ?? _categoryForItem(itemName),
        itemType: data?.asItemType ?? _itemTypeForItem(itemName),
        quantity: qty,
        properties: data?.properties ?? _propertiesForItem(itemName),
      ));
    }

    // Fixed items
    for (final itemName in draft.selectedStartingEquipment) {
      addItem(itemName);
    }
    // Resolved background equipment choices (e.g. chosen instrument)
    for (final itemName in draft.resolvedEquipmentChoices.values) {
      addItem(itemName);
    }
    // Class starting equipment
    final classEquip = draft.selectedClass?.startingEquipment;
    if (classEquip != null) {
      // Fixed class items
      for (final item in classEquip.fixed) {
        if (!item.toLowerCase().startsWith('any ')) addItem(item);
      }
      // Chosen option items
      for (int g = 0; g < classEquip.choices.length; g++) {
        if (g >= draft.classEquipmentChoices.length) continue;
        final optIdx = draft.classEquipmentChoices[g];
        if (optIdx == null) continue;
        final option = classEquip.choices[g].options[optIdx];
        for (int i = 0; i < option.length; i++) {
          final item = option[i];
          if (item.toLowerCase().startsWith('any ')) {
            final specific = draft.classEquipmentSpecifics['$g:$i'];
            if (specific != null) addItem(specific);
          } else {
            addItem(item);
          }
        }
      }
    }

    // Equipa a primeira armadura de corpo e o escudo (se houver).
    EquipmentItem? bodyArmor;
    EquipmentItem? shield;
    for (final item in startingEquipment) {
      if (item.itemType != ItemType.armor) continue;
      if (item.properties?['isShield'] == true) {
        shield ??= item;
      } else {
        bodyArmor ??= item;
      }
    }
    // Marca como equipado na lista
    for (int i = 0; i < startingEquipment.length; i++) {
      if (identical(startingEquipment[i], bodyArmor) ||
          identical(startingEquipment[i], shield)) {
        startingEquipment[i] = startingEquipment[i].copyWith(isEquipped: true);
      }
    }

    var character = Character(
      id: draft.id,
      name: draft.name.trim().isEmpty ? fallbackName : draft.name.trim(),
      playerName: draft.playerName,
      race: draft.selectedRace!.name,
      subrace: draft.selectedSubrace?.name,
      characterClass: draft.selectedClass!.name,
      subclass: draft.selectedSubclass?.name,
      level: 1,
      experiencePoints: 0,
      background: draft.selectedBackground!.name,
      alignment: '',
      abilityScores: AbilityScores(
        strength: attrs['Strength'] ?? 10,
        dexterity: attrs['Dexterity'] ?? 10,
        constitution: con,
        intelligence: attrs['Intelligence'] ?? 10,
        wisdom: attrs['Wisdom'] ?? 10,
        charisma: attrs['Charisma'] ?? 10,
      ),
      hitPoints: HitPoints(
        maximum: hitDie + conMod,
        current: hitDie + conMod,
        temporary: 0,
      ),
      armorClass: 10,
      speed: draft.selectedRace!.speed,
      proficiencyBonus: 2,
      savingThrowProficiencies: draft.selectedClass!.savingThrows,
      skillProficiencies: [
        ...draft.grantedSkills,
        ...draft.chosenSkills,
      ],
      skillExpertises: [],
      equipment: startingEquipment,
      currency: {'cp': 0, 'sp': 0, 'ep': 0, 'gp': startingGp, 'pp': 0},
      spells: [],
      spellSlots: SpellSlots(
        total: List.filled(9, 0),
        used: List.filled(9, 0),
      ),
      features: draft.chosenToolProficiencies
          .where((t) => t.isNotEmpty)
          .map((t) => 'Tool Proficiency: $t')
          .toList(),
      languages: [...draft.fixedRaceLanguages, ...draft.chosenLanguages],
      personality: const CharacterPersonality(
        traits: '',
        ideals: '',
        bonds: '',
        flaws: '',
      ),
      appearance: const CharacterAppearance(
        height: '',
        weight: '',
        eyes: '',
        skin: '',
        hair: '',
      ),
      backstory: '',
      creationMode: CreationMode.guided,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    character = character.copyWith(armorClass: calcArmorClass(character));

    await repo.save(character);
    return character;
  }
}

final characterDraftProvider =
    NotifierProvider<CharacterDraftNotifier, CharacterDraft>(
  CharacterDraftNotifier.new,
);
