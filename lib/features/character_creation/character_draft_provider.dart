import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/srd/srd_models.dart';
import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';

// ── Estado do rascunho ────────────────────────────────────────────────────────

enum AttributeMethod { standardArray, pointBuy }

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
  });

  CharacterDraft copyWith({
    SrdClass? selectedClass,
    Object? selectedSubclass = _sentinel,
    SrdRace? selectedRace,
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
  }) {
    return CharacterDraft(
      id: id,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedSubclass: selectedSubclass == _sentinel
          ? this.selectedSubclass
          : selectedSubclass as SrdSubclass?,
      selectedRace: selectedRace ?? this.selectedRace,
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
      );

  void setSubclass(SrdSubclass? s) =>
      state = state.copyWith(selectedSubclass: s);

  void setRace(SrdRace r) => state = state.copyWith(
        selectedRace: r,
        selectedSubrace: null,
        freePicksDistribution: {},
      );

  void setSubrace(SrdSubrace? s) =>
      state = state.copyWith(selectedSubrace: s);

  void setBackground(SrdBackground b) =>
      state = state.copyWith(selectedBackground: b);

  void setChosenSkills(List<String> skills) =>
      state = state.copyWith(chosenSkills: skills);

  void setBaseAttributes(Map<String, int> attrs) =>
      state = state.copyWith(baseAttributes: attrs);

  void setAttributeMethod(AttributeMethod m) =>
      state = state.copyWith(attributeMethod: m);

  void setFreeAsi(bool v) => state = state.copyWith(freeAsi: v);

  void setFreeAsiDistribution(Map<String, int> dist) =>
      state = state.copyWith(freeAsiDistribution: dist);

  void setFreePicksDistribution(Map<String, int> dist) =>
      state = state.copyWith(freePicksDistribution: dist);

  void setName(String n) => state = state.copyWith(name: n);
  void setPlayerName(String n) => state = state.copyWith(playerName: n);

  Future<Character> buildAndSave(WidgetRef ref) async {
    final draft = state;
    final repo = ref.read(characterRepositoryProvider);
    final attrs = draft.finalAttributes;

    final con = attrs['Constitution'] ?? 10;
    final conMod = ((con - 10) / 2).floor();
    final hitDie = draft.selectedClass!.hitDie;

    final character = Character(
      id: draft.id,
      name: draft.name.isEmpty ? 'Unnamed Hero' : draft.name,
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
      armorClass: 10 + (((attrs['Dexterity'] ?? 10) - 10) / 2).floor(),
      speed: draft.selectedRace!.speed,
      proficiencyBonus: 2,
      savingThrowProficiencies: draft.selectedClass!.savingThrows,
      skillProficiencies: [
        ...draft.grantedSkills,
        ...draft.chosenSkills,
      ],
      skillExpertises: [],
      equipment: [],
      spells: [],
      spellSlots: SpellSlots(
        total: List.filled(9, 0),
        used: List.filled(9, 0),
      ),
      features: [],
      languages: draft.selectedRace!.languages,
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

    await repo.save(character);
    return character;
  }
}

final characterDraftProvider =
    NotifierProvider<CharacterDraftNotifier, CharacterDraft>(
  CharacterDraftNotifier.new,
);
