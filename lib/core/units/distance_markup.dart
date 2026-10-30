import 'unit_system_provider.dart';

/// Distances in rules text are written as markers so they follow the unit
/// preference instead of the language of the text:
///
/// - `{{distance:30ft}}` renders "30 feet", "9 metros" or "6 casillas".
/// - `{{distance:20/60ft}}` is a pair of ranges ("20/60 feet", "6/18 m").
/// - `{{distance:10+ft}}` means that distance or more ("10+ feet").
/// - `{{distance:10ft|adj}}` is the attributive form ("10-foot", "3-Meter"
///   before "-Würfel", "3-метров" before "ый").
/// - `{{distance:30ft|short}}` is the abbreviation used in stat blocks.
/// - `{{distance:11ft|num}}` is only the number ("11 to 20 ft.").
/// - Other forms are grammatical cases of one language, such as `dat` in
///   German, `gen`/`prep` in Russian, `dat`/`abl` in Turkish or `obj` in
///   Korean. A form a language does not define renders as the plain form.
///
/// Values are in the units of the books (`ft`, `in`, `mi`). Metric follows
/// the official translations: 5 ft = 1.5 m, 1 in = 2.5 cm, 1 mi = 1.5 km,
/// with less than a meter in centimeters (1 ft = 30 cm).
/// Squares are 5 ft; distances that are not whole squares use the language's
/// official system.
class DistanceMarkup {
  const DistanceMarkup._();

  static final pattern = RegExp(
    r'\{\{distance:(\d+(?:\.\d+)?)(?:/(\d+(?:\.\d+)?))?(\+)?(ft|in|mi)(?:\|([a-z]+))?\}\}',
  );

  static bool hasMarkers(String text) => text.contains('{{distance:');

  /// Replaces every marker in [text] with the distance in [system], written
  /// in the language [languageCode]. Unknown languages use English.
  static String render(
    String text, {
    required String languageCode,
    required UnitSystem system,
  }) {
    if (!hasMarkers(text)) return text;
    final language = _languages[languageCode] ?? _languages['en']!;
    return text.replaceAllMapped(pattern, (m) {
      final values = [double.parse(m[1]!), if (m[2] != null) double.parse(m[2]!)];
      final text = _renderOne(language, languageCode, values, m[4]!, m[5], system);
      if (m[3] == null) return text;
      final number = _renderOne(language, languageCode, values, m[4]!, 'num', system);
      return '$number+${text.substring(number.length)}';
    });
  }

  static String _renderOne(
    _Language language,
    String languageCode,
    List<double> values,
    String unit,
    String? form,
    UnitSystem system,
  ) {
    var shownSystem = system;
    if (system == UnitSystem.squares &&
        (unit != 'ft' || values.any((v) => v % 5 != 0))) {
      shownSystem = officialUnitSystem(languageCode);
    }
    var (shown, factor) = switch ((shownSystem, unit)) {
      (UnitSystem.imperial, _) => (unit, 1.0),
      (UnitSystem.metric, 'ft') => ('m', 0.3),
      (UnitSystem.metric, 'in') => ('cm', 2.5),
      (UnitSystem.metric, _) => ('km', 1.5),
      (UnitSystem.squares, _) => ('sq', 0.2),
    };
    if (shown == 'm' && values.last > 0 && values.last * factor < 1) {
      (shown, factor) = ('cm', factor * 100);
    } else if (shown == 'cm' && values.first * factor >= 100) {
      (shown, factor) = ('m', factor / 100);
    }
    // Centimeters keep one decimal (1/2 in = 1,3 cm).
    final precision = shown == 'cm' ? 10 : 100;
    final shownValues = [for (final v in values) (v * factor * precision).round() / precision];
    // The books write fractions of imperial units as "1/2 inch".
    final fraction = shownSystem == UnitSystem.imperial ? _fractions[shownValues.last] : null;
    final number = fraction != null && shownValues.length == 1
        ? fraction
        : shownValues.map(language.formatNumber).join('/');
    if (form == 'num') return number;
    final category = fraction != null ? language.fractionCategory : language.plural(shownValues.last);
    final (separator, word) = language.word(shown, form, category);
    return '$number$separator$word';
  }
}

final _fractions = <double, String>{0.25: '1/4', 0.5: '1/2', 0.75: '3/4'};

/// Plural categories, as in CLDR.
enum _Plural { one, few, many, other }

/// The words of one form: one list per shown unit, with an entry per plural
/// category in [_Language.categories] order, or a single invariant entry.
class _Form {
  const _Form(this.separator, this.words);

  final String separator;
  final Map<String, List<String>> words;
}

class _Language {
  const _Language({
    required this.decimal,
    required this.group,
    required this.plural,
    required this.forms,
    this.categories = const [_Plural.one, _Plural.other],
    this.fractionCategory = _Plural.one,
  });

  final String decimal;
  final String group;
  final _Plural Function(double value) plural;
  final List<_Plural> categories;

  /// The category of "1/2 inch": singular in most languages, genitive
  /// singular ("1/2 дюйма") in Russian.
  final _Plural fractionCategory;

  /// Form name (`''` for the plain form) to its words.
  final Map<String, _Form> forms;

  (String, String) word(String unit, String? form, _Plural category) {
    final plain = forms['']!;
    final chosen = forms[form ?? ''];
    final words = chosen?.words[unit] ?? plain.words[unit]!;
    final separator = chosen?.words[unit] != null ? chosen!.separator : plain.separator;
    if (words.length == 1) return (separator, words.single);
    final index = categories.indexOf(category);
    return (separator, words[index < 0 ? words.length - 1 : index]);
  }

  String formatNumber(double value) {
    final whole = value.truncate();
    final fraction = ((value - whole) * 100).round();
    final digits = whole.toString();
    final grouped = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(group);
      grouped.write(digits[i]);
    }
    if (fraction == 0) return grouped.toString();
    final decimals = fraction.toString().padLeft(2, '0').replaceFirst(RegExp(r'0$'), '');
    return '$grouped$decimal$decimals';
  }
}

_Plural _oneIfExactlyOne(double v) => v == 1 ? _Plural.one : _Plural.other;

/// Portuguese and French use the singular below 2 ("1,5 metro").
_Plural _oneBelowTwo(double v) => v < 2 ? _Plural.one : _Plural.other;

_Plural _noPlural(double v) => _Plural.other;

_Plural _russian(double v) {
  if (v % 1 != 0) return _Plural.other;
  final n = v.toInt();
  if (n % 10 == 1 && n % 100 != 11) return _Plural.one;
  if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 12 || n % 100 > 14)) return _Plural.few;
  return _Plural.many;
}

const _russianCategories = [_Plural.one, _Plural.few, _Plural.many, _Plural.other];

/// Builds Turkish case forms: each unit's word with its own suffix, since
/// vowel harmony and buffer letters differ between "fit" and "metre".
Map<String, List<String>> _turkish(List<String> suffixes) => {
  for (final (i, unit) in const ['ft', 'in', 'mi', 'm', 'cm', 'km', 'sq'].indexed)
    unit: [const ['fit', 'inç', 'mil', 'metre', 'santimetre', 'kilometre', 'kare'][i] + suffixes[i]],
};

/// Builds Korean particle forms; [vowel] follows words ending in a vowel and
/// [consonant] follows 마일 and 칸.
Map<String, List<String>> _korean(String vowel, String consonant, {String? afterL}) => {
  'ft': ['피트$vowel'],
  'in': ['인치$vowel'],
  'mi': ['마일${afterL ?? consonant}'],
  'm': ['미터$vowel'],
  'cm': ['센티미터$vowel'],
  'km': ['킬로미터$vowel'],
  'sq': ['칸$consonant'],
};

const _metricShort = {
  'm': ['m'],
  'cm': ['cm'],
  'km': ['km'],
};

final Map<String, _Language> _languages = {
  'en': _Language(
    decimal: '.',
    group: ',',
    plural: _oneIfExactlyOne,
    forms: const {
      '': _Form(' ', {
        'ft': ['foot', 'feet'],
        'in': ['inch', 'inches'],
        'mi': ['mile', 'miles'],
        'm': ['meter', 'meters'],
        'cm': ['centimeter', 'centimeters'],
        'km': ['kilometer', 'kilometers'],
        'sq': ['square', 'squares'],
      }),
      'adj': _Form('-', {
        'ft': ['foot'],
        'in': ['inch'],
        'mi': ['mile'],
        'm': ['meter'],
        'cm': ['centimeter'],
        'km': ['kilometer'],
        'sq': ['square'],
      }),
      'short': _Form(' ', {
        'ft': ['ft.'],
        'in': ['in.'],
        'mi': ['mi.'],
        ..._metricShort,
        'sq': ['sq.'],
      }),
    },
  ),
  'pt': _Language(
    decimal: ',',
    group: '.',
    plural: _oneBelowTwo,
    forms: const {
      '': _Form(' ', {
        'ft': ['pé', 'pés'],
        'in': ['polegada', 'polegadas'],
        'mi': ['milha', 'milhas'],
        'm': ['metro', 'metros'],
        'cm': ['centímetro', 'centímetros'],
        'km': ['quilômetro', 'quilômetros'],
        'sq': ['quadrado', 'quadrados'],
      }),
      'short': _Form(' ', _metricShort),
    },
  ),
  'es': _Language(
    decimal: ',',
    group: '.',
    plural: _oneIfExactlyOne,
    forms: const {
      '': _Form(' ', {
        'ft': ['pie', 'pies'],
        'in': ['pulgada', 'pulgadas'],
        'mi': ['milla', 'millas'],
        'm': ['metro', 'metros'],
        'cm': ['centímetro', 'centímetros'],
        'km': ['kilómetro', 'kilómetros'],
        'sq': ['casilla', 'casillas'],
      }),
      'short': _Form(' ', _metricShort),
    },
  ),
  'fr': _Language(
    decimal: ',',
    group: ' ',
    plural: _oneBelowTwo,
    forms: const {
      '': _Form(' ', {
        'ft': ['pied', 'pieds'],
        'in': ['pouce', 'pouces'],
        'mi': ['mille', 'milles'],
        'm': ['mètre', 'mètres'],
        'cm': ['centimètre', 'centimètres'],
        'km': ['kilomètre', 'kilomètres'],
        'sq': ['case', 'cases'],
      }),
      'short': _Form(' ', _metricShort),
    },
  ),
  'it': _Language(
    decimal: ',',
    group: '.',
    plural: _oneIfExactlyOne,
    forms: const {
      '': _Form(' ', {
        'ft': ['piede', 'piedi'],
        'in': ['pollice', 'pollici'],
        'mi': ['miglio', 'miglia'],
        'm': ['metro', 'metri'],
        'cm': ['centimetro', 'centimetri'],
        'km': ['chilometro', 'chilometri'],
        'sq': ['quadretto', 'quadretti'],
      }),
      'short': _Form(' ', _metricShort),
    },
  ),
  'de': _Language(
    decimal: ',',
    group: '.',
    plural: _oneIfExactlyOne,
    forms: const {
      '': _Form(' ', {
        'ft': ['Fuß'],
        'in': ['Zoll'],
        'mi': ['Meile', 'Meilen'],
        'm': ['Meter'],
        'cm': ['Zentimeter'],
        'km': ['Kilometer'],
        'sq': ['Feld', 'Felder'],
      }),
      'dat': _Form(' ', {
        'm': ['Meter', 'Metern'],
        'cm': ['Zentimeter', 'Zentimetern'],
        'km': ['Kilometer', 'Kilometern'],
        'sq': ['Feld', 'Feldern'],
      }),
      'adj': _Form('-', {
        'ft': ['Fuß'],
        'in': ['Zoll'],
        'mi': ['Meilen'],
        'm': ['Meter'],
        'cm': ['Zentimeter'],
        'km': ['Kilometer'],
        'sq': ['Felder'],
      }),
      // "9-m-Kegel", "30-Fuß-Kegel".
      'shortadj': _Form('-', {
        'ft': ['Fuß'],
        'in': ['Zoll'],
        'mi': ['Meilen'],
        ..._metricShort,
        'sq': ['Felder'],
      }),
      'short': _Form(' ', _metricShort),
    },
  ),
  'ru': _Language(
    decimal: ',',
    group: ' ',
    plural: _russian,
    categories: _russianCategories,
    fractionCategory: _Plural.other,
    forms: const {
      '': _Form(' ', {
        'ft': ['фут', 'фута', 'футов', 'фута'],
        'in': ['дюйм', 'дюйма', 'дюймов', 'дюйма'],
        'mi': ['миля', 'мили', 'миль', 'мили'],
        'm': ['метр', 'метра', 'метров', 'метра'],
        'cm': ['сантиметр', 'сантиметра', 'сантиметров', 'сантиметра'],
        'km': ['километр', 'километра', 'километров', 'километра'],
        'sq': ['клетка', 'клетки', 'клеток', 'клетки'],
      }),
      'acc': _Form(' ', {
        'mi': ['милю', 'мили', 'миль', 'мили'],
        'sq': ['клетку', 'клетки', 'клеток', 'клетки'],
      }),
      'gen': _Form(' ', {
        'ft': ['фута', 'футов', 'футов', 'фута'],
        'in': ['дюйма', 'дюймов', 'дюймов', 'дюйма'],
        'mi': ['мили', 'миль', 'миль', 'мили'],
        'm': ['метра', 'метров', 'метров', 'метра'],
        'cm': ['сантиметра', 'сантиметров', 'сантиметров', 'сантиметра'],
        'km': ['километра', 'километров', 'километров', 'километра'],
        'sq': ['клетки', 'клеток', 'клеток', 'клетки'],
      }),
      'dat': _Form(' ', {
        'ft': ['футу', 'футам', 'футам', 'фута'],
        'in': ['дюйму', 'дюймам', 'дюймам', 'дюйма'],
        'mi': ['миле', 'милям', 'милям', 'мили'],
        'm': ['метру', 'метрам', 'метрам', 'метра'],
        'cm': ['сантиметру', 'сантиметрам', 'сантиметрам', 'сантиметра'],
        'km': ['километру', 'километрам', 'километрам', 'километра'],
        'sq': ['клетке', 'клеткам', 'клеткам', 'клетки'],
      }),
      'inst': _Form(' ', {
        'ft': ['футом', 'футами', 'футами', 'фута'],
        'in': ['дюймом', 'дюймами', 'дюймами', 'дюйма'],
        'mi': ['милей', 'милями', 'милями', 'мили'],
        'm': ['метром', 'метрами', 'метрами', 'метра'],
        'cm': ['сантиметром', 'сантиметрами', 'сантиметрами', 'сантиметра'],
        'km': ['километром', 'километрами', 'километрами', 'километра'],
        'sq': ['клеткой', 'клетками', 'клетками', 'клетки'],
      }),
      'prep': _Form(' ', {
        'ft': ['футе', 'футах', 'футах', 'фута'],
        'in': ['дюйме', 'дюймах', 'дюймах', 'дюйма'],
        'mi': ['миле', 'милях', 'милях', 'мили'],
        'm': ['метре', 'метрах', 'метрах', 'метра'],
        'cm': ['сантиметре', 'сантиметрах', 'сантиметрах', 'сантиметра'],
        'km': ['километре', 'километрах', 'километрах', 'километра'],
        'sq': ['клетке', 'клетках', 'клетках', 'клетки'],
      }),
      // Hard-stem adjectives: the ending follows the marker ("-футовый").
      'adj': _Form('-', {
        'ft': ['футов'],
        'in': ['дюймов'],
        'mi': ['мильн'],
        'm': ['метров'],
        'cm': ['сантиметров'],
        'km': ['километров'],
        'sq': ['клеточн'],
      }),
      'short': _Form(' ', {
        'ft': ['фт.'],
        'm': ['м'],
        'cm': ['см'],
        'km': ['км'],
      }),
    },
  ),
  'tr': _Language(
    decimal: ',',
    group: '.',
    plural: _noPlural,
    forms: {
      '': _Form(' ', _turkish(const ['', '', '', '', '', '', ''])),
      'lik': _Form(' ', _turkish(const ['lik', 'lik', 'lik', 'lik', 'lik', 'lik', 'lik'])),
      'dat': _Form(' ', _turkish(const ['e', 'e', 'e', 'ye', 'ye', 'ye', 'ye'])),
      'acc': _Form(' ', _turkish(const ['i', 'i', 'i', 'yi', 'yi', 'yi', 'yi'])),
      'loc': _Form(' ', _turkish(const ['te', 'te', 'de', 'de', 'de', 'de', 'de'])),
      'abl': _Form(' ', _turkish(const ['ten', 'ten', 'den', 'den', 'den', 'den', 'den'])),
      'gen': _Form(' ', _turkish(const ['in', 'in', 'in', 'nin', 'nin', 'nin', 'nin'])),
      'ins': _Form(' ', _turkish(const ['le', 'le', 'le', 'yle', 'yle', 'yle', 'yle'])),
      // Copula: "300 fittir".
      'cop': _Form(' ', _turkish(const ['tir', 'tir', 'dir', 'dir', 'dir', 'dir', 'dir'])),
      'short': const _Form(' ', {'ft': ['ft'], ..._metricShort}),
    },
  ),
  'ja': _Language(
    decimal: '.',
    group: ',',
    plural: _noPlural,
    forms: const {
      '': _Form('', {
        'ft': ['フィート'],
        'in': ['インチ'],
        'mi': ['マイル'],
        'm': ['メートル'],
        'cm': ['センチメートル'],
        'km': ['キロメートル'],
        'sq': ['マス'],
      }),
    },
  ),
  'ko': _Language(
    decimal: '.',
    group: ',',
    plural: _noPlural,
    forms: {
      '': _Form('', _korean('', '')),
      'obj': _Form('', _korean('를', '을')),
      'subj': _Form('', _korean('가', '이')),
      'top': _Form('', _korean('는', '은')),
      'dir': _Form('', _korean('로', '으로', afterL: '로')),
      'and': _Form('', _korean('와', '과')),
    },
  ),
  'zh': _Language(
    decimal: '.',
    group: ',',
    plural: _noPlural,
    forms: const {
      '': _Form('', {
        'ft': ['英尺'],
        'in': ['英寸'],
        'mi': ['英里'],
        'm': ['米'],
        'cm': ['厘米'],
        'km': ['千米'],
        'sq': ['格'],
      }),
      'short': _Form('', {'ft': ['尺']}),
    },
  ),
};
