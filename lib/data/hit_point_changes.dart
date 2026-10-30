import 'models/models.dart';

/// Damage and healing of the sheet, including a 2014 Wild Shape form, which
/// has hit points of its own.
class HitPointChanges {
  const HitPointChanges._();

  /// Damage (negative [delta]) drains Temporary Hit Points first. A 2014 form
  /// then loses its own hit points; at 0 the Druid reverts and the excess
  /// carries over. Healing a 2014 form heals the form.
  static Character apply(Character character, int delta) {
    final form = character.wildShape;
    final formHp = form?.hitPoints;
    if (form == null || formHp == null) return _applyToCharacter(character, delta);
    final hp = character.hitPoints;
    if (delta >= 0) {
      final max = form.maxHitPoints ?? formHp;
      return character.copyWith(
        wildShape: form.copyWith(hitPoints: (formHp + delta).clamp(0, max)),
      );
    }
    var damage = -delta;
    final absorbed = damage < hp.temporary ? damage : hp.temporary;
    damage -= absorbed;
    final afterTemp = character.copyWith(
      hitPoints: hp.copyWith(temporary: hp.temporary - absorbed),
    );
    if (damage < formHp) {
      return afterTemp.copyWith(wildShape: form.copyWith(hitPoints: formHp - damage));
    }
    return _applyToCharacter(
      afterTemp.copyWith(wildShape: null),
      -(damage - formHp),
    );
  }

  static Character _applyToCharacter(Character character, int delta) {
    final hp = character.hitPoints;
    var temporary = hp.temporary;
    var current = hp.current;
    if (delta < 0) {
      final damage = -delta;
      if (temporary >= damage) {
        temporary -= damage;
      } else {
        current = (current - (damage - temporary)).clamp(0, hp.maximum);
        temporary = 0;
      }
    } else {
      // Healing only affects real hit points.
      current = (current + delta).clamp(0, hp.maximum);
    }
    // Recovering from 0 hit points resets death saves.
    final resetDeathSaves = hp.isDead && (current > 0 || temporary > 0);
    return character.copyWith(
      hitPoints: hp.copyWith(
        current: current,
        temporary: temporary,
        deathSaveSuccesses: resetDeathSaves ? 0 : null,
        deathSaveFailures: resetDeathSaves ? 0 : null,
      ),
    );
  }
}
