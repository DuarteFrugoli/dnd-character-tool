import 'unit_system_provider.dart';

/// Distances, areas and volumes in rules text are written as markers so they
/// follow the unit preference instead of the language of the text:
///
/// - `{{distance:30ft}}` renders "30 feet", "9 metros" or "6 casillas".
/// - `{{distance:20/60ft}}` is a pair of ranges ("20/60 feet", "6/18 m").
/// - `{{distance:10+ft}}` means that distance or more ("10+ feet").
/// - `{{area:2500sqft}}` renders "2,500 square feet", "225 metros quadrados"
///   or "100 squares".
/// - `{{volume:12cuft}}` renders "12 cubic feet" or "324 litros";
///   `{{volume:10gal}}`, `{{volume:1pint}}` and `{{volume:4floz}}` are liquid
///   measures.
/// - `|adj` is the attributive form ("10-foot", "3-Meter" before "-Würfel",
///   "3-метров" before "ый", "4-ounce").
/// - `|short` is the abbreviation used in stat blocks.
/// - `|num` is only the number ("11 to 20 ft.").
/// - Other forms are grammatical cases of one language, such as `dat` in
///   German, `gen`/`prep` in Russian, `dat`/`abl` in Turkish or `obj` in
///   Korean. A form a language does not define renders as the plain form.
///
/// Values are in the units of the books: `ft`, `in`, `mi`; `sqft`, `sqmi`;
/// `cuft`, `cuin`, `gal`, `pint`, `floz`. Metric follows the official
/// translations, 5 ft = 1.5 m: 1 in = 2.5 cm, 1 mi = 1.5 km, 1 sq ft =
/// 0.09 m², 1 cu ft = 27 L, 1 gal = 4 L, 1 pint = 0.5 L, 1 oz = 30 mL. Less
/// than a meter shows in centimeters (1 ft = 30 cm), a thousand liters or
/// more in cubic meters. Squares are 5 ft (25 sq ft); measures that are not
/// whole squares, and volumes, use the language's official system.
class MeasureMarkup {
  const MeasureMarkup._();

  static final pattern = RegExp(
    r'\{\{(distance|area|volume):(\d+(?:\.\d+)?)(?:/(\d+(?:\.\d+)?))?(\+)?([a-z]+)(?:\|([a-z]+))?\}\}',
  );

  /// The units each kind of marker accepts.
  static const units = {
    'distance': {'ft', 'in', 'mi'},
    'area': {'sqft', 'sqmi'},
    'volume': {'cuft', 'cuin', 'gal', 'pint', 'floz'},
  };

  static bool hasMarkers(String text) =>
      text.contains('{{distance:') || text.contains('{{area:') || text.contains('{{volume:');

  /// Replaces every marker in [text] with the measure in [system], written
  /// in the language [languageCode]. Unknown languages use English.
  static String render(
    String text, {
    required String languageCode,
    required UnitSystem system,
  }) {
    if (!hasMarkers(text)) return text;
    final language = _languages[languageCode] ?? _languages['en']!;
    return text.replaceAllMapped(pattern, (m) {
      if (!(units[m[1]]?.contains(m[5]) ?? false)) return m[0]!;
      final values = [double.parse(m[2]!), if (m[3] != null) double.parse(m[3]!)];
      final text = _renderOne(language, languageCode, values, m[5]!, m[6], system);
      if (m[4] == null) return text;
      final number = _renderOne(language, languageCode, values, m[5]!, 'num', system);
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
    if (system == UnitSystem.squares) {
      final square = _squareSize[unit];
      if (square == null || values.any((v) => v % square != 0)) {
        shownSystem = officialUnitSystem(languageCode);
      }
    }
    var (shown, factor) = switch (shownSystem) {
      UnitSystem.imperial => (unit, 1.0),
      UnitSystem.metric => _metric[unit]!,
      UnitSystem.squares => ('sq', 1 / _squareSize[unit]!),
    };
    if (_smaller[shown] case (final small, final scale) when values.last > 0 && values.last * factor < 1) {
      (shown, factor) = (small, factor * scale);
    } else if (_larger[shown] case (final large, final threshold, final scale)
        when values.first * factor >= threshold) {
      (shown, factor) = (large, factor * scale);
    }
    final precision = _precision[shown] ?? 100;
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

/// Imperial units in a 5-ft square.
const _squareSize = {'ft': 5.0, 'sqft': 25.0};

/// Metric unit and factor for each imperial unit.
const _metric = {
  'ft': ('m', 0.3),
  'in': ('cm', 2.5),
  'mi': ('km', 1.5),
  'sqft': ('m2', 0.09),
  'sqmi': ('km2', 2.25),
  'cuft': ('l', 27.0),
  'cuin': ('cm3', 15.625),
  'gal': ('l', 4.0),
  'pint': ('l', 0.5),
  'floz': ('ml', 30.0),
};

/// Below 1, these units show in a smaller one.
const _smaller = {'m': ('cm', 100.0), 'm2': ('cm2', 10000.0)};

/// From the threshold up, these units show in a larger one.
const _larger = {
  'cm': ('m', 100.0, 0.01),
  'l': ('m3', 1000.0, 0.001),
  'ml': ('l', 1000.0, 0.001),
};

/// Rounding per shown unit: 10 is one decimal, 1 none; default two.
const _precision = {'cm': 10, 'cm2': 1, 'cm3': 1, 'ml': 1, 'l': 10, 'm3': 10};

final _fractions = <double, String>{0.2: '1/5', 0.25: '1/4', 0.5: '1/2', 0.75: '3/4'};

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

/// Korean unit words and how they end: 0 a vowel, 1 a consonant, 2 ㄹ.
const _koreanWords = {
  'ft': ('피트', 0),
  'in': ('인치', 0),
  'mi': ('마일', 2),
  'm': ('미터', 0),
  'cm': ('센티미터', 0),
  'km': ('킬로미터', 0),
  'sq': ('칸', 1),
  'sqft': ('제곱피트', 0),
  'sqmi': ('제곱마일', 2),
  'm2': ('제곱미터', 0),
  'km2': ('제곱킬로미터', 0),
  'cm2': ('제곱센티미터', 0),
  'cuft': ('세제곱피트', 0),
  'cuin': ('세제곱인치', 0),
  'm3': ('세제곱미터', 0),
  'cm3': ('세제곱센티미터', 0),
  'gal': ('갤런', 1),
  'pint': ('파인트', 0),
  'floz': ('온스', 0),
  'l': ('리터', 0),
  'ml': ('밀리리터', 0),
};

/// Builds Korean particle forms: the particle after a vowel, a consonant
/// and ㄹ (which takes 로 like a vowel).
Map<String, List<String>> _korean(String vowel, String consonant, [String? rieul]) => {
  for (final MapEntry(key: unit, value: (word, ending)) in _koreanWords.entries)
    unit: [word + [vowel, consonant, rieul ?? consonant][ending]],
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
        'sqft': ['square foot', 'square feet'],
        'sqmi': ['square mile', 'square miles'],
        'm2': ['square meter', 'square meters'],
        'km2': ['square kilometer', 'square kilometers'],
        'cm2': ['square centimeter', 'square centimeters'],
        'cuft': ['cubic foot', 'cubic feet'],
        'cuin': ['cubic inch', 'cubic inches'],
        'm3': ['cubic meter', 'cubic meters'],
        'cm3': ['cubic centimeter', 'cubic centimeters'],
        'gal': ['gallon', 'gallons'],
        'pint': ['pint', 'pints'],
        'floz': ['ounce', 'ounces'],
        'l': ['liter', 'liters'],
        'ml': ['milliliter', 'milliliters'],
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
        'sqft': ['square-foot'],
        'cuft': ['cubic-foot'],
        'gal': ['gallon'],
        'pint': ['pint'],
        'floz': ['ounce'],
        'l': ['liter'],
        'ml': ['milliliter'],
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
        'sqft': ['pé quadrado', 'pés quadrados'],
        'sqmi': ['milha quadrada', 'milhas quadradas'],
        'm2': ['metro quadrado', 'metros quadrados'],
        'km2': ['quilômetro quadrado', 'quilômetros quadrados'],
        'cm2': ['centímetro quadrado', 'centímetros quadrados'],
        'cuft': ['pé cúbico', 'pés cúbicos'],
        'cuin': ['polegada cúbica', 'polegadas cúbicas'],
        'm3': ['metro cúbico', 'metros cúbicos'],
        'cm3': ['centímetro cúbico', 'centímetros cúbicos'],
        'gal': ['galão', 'galões'],
        'pint': ['quartilho', 'quartilhos'],
        'floz': ['onça', 'onças'],
        'l': ['litro', 'litros'],
        'ml': ['mililitro', 'mililitros'],
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
        'sqft': ['pie cuadrado', 'pies cuadrados'],
        'sqmi': ['milla cuadrada', 'millas cuadradas'],
        'm2': ['metro cuadrado', 'metros cuadrados'],
        'km2': ['kilómetro cuadrado', 'kilómetros cuadrados'],
        'cm2': ['centímetro cuadrado', 'centímetros cuadrados'],
        'cuft': ['pie cúbico', 'pies cúbicos'],
        'cuin': ['pulgada cúbica', 'pulgadas cúbicas'],
        'm3': ['metro cúbico', 'metros cúbicos'],
        'cm3': ['centímetro cúbico', 'centímetros cúbicos'],
        'gal': ['galón', 'galones'],
        'pint': ['pinta', 'pintas'],
        'floz': ['onza', 'onzas'],
        'l': ['litro', 'litros'],
        'ml': ['mililitro', 'mililitros'],
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
        'sqft': ['pied carré', 'pieds carrés'],
        'sqmi': ['mille carré', 'milles carrés'],
        'm2': ['mètre carré', 'mètres carrés'],
        'km2': ['kilomètre carré', 'kilomètres carrés'],
        'cm2': ['centimètre carré', 'centimètres carrés'],
        'cuft': ['pied cube', 'pieds cubes'],
        'cuin': ['pouce cube', 'pouces cubes'],
        'm3': ['mètre cube', 'mètres cubes'],
        'cm3': ['centimètre cube', 'centimètres cubes'],
        'gal': ['gallon', 'gallons'],
        'pint': ['pinte', 'pintes'],
        'floz': ['once', 'onces'],
        'l': ['litre', 'litres'],
        'ml': ['millilitre', 'millilitres'],
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
        'sqft': ['piede quadrato', 'piedi quadrati'],
        'sqmi': ['miglio quadrato', 'miglia quadrate'],
        'm2': ['metro quadrato', 'metri quadrati'],
        'km2': ['chilometro quadrato', 'chilometri quadrati'],
        'cm2': ['centimetro quadrato', 'centimetri quadrati'],
        'cuft': ['piede cubo', 'piedi cubi'],
        'cuin': ['pollice cubo', 'pollici cubi'],
        'm3': ['metro cubo', 'metri cubi'],
        'cm3': ['centimetro cubo', 'centimetri cubi'],
        'gal': ['gallone', 'galloni'],
        'pint': ['pinta', 'pinte'],
        'floz': ['oncia', 'once'],
        'l': ['litro', 'litri'],
        'ml': ['millilitro', 'millilitri'],
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
        'sqft': ['Quadratfuß'],
        'sqmi': ['Quadratmeile', 'Quadratmeilen'],
        'm2': ['Quadratmeter'],
        'km2': ['Quadratkilometer'],
        'cm2': ['Quadratzentimeter'],
        'cuft': ['Kubikfuß'],
        'cuin': ['Kubikzoll'],
        'm3': ['Kubikmeter'],
        'cm3': ['Kubikzentimeter'],
        'gal': ['Gallone', 'Gallonen'],
        'pint': ['Pint', 'Pints'],
        'floz': ['Unze', 'Unzen'],
        'l': ['Liter'],
        'ml': ['Milliliter'],
        'sq': ['Feld', 'Felder'],
      }),
      'dat': _Form(' ', {
        'm': ['Meter', 'Metern'],
        'cm': ['Zentimeter', 'Zentimetern'],
        'km': ['Kilometer', 'Kilometern'],
        'sq': ['Feld', 'Feldern'],
        'm2': ['Quadratmeter', 'Quadratmetern'],
        'km2': ['Quadratkilometer', 'Quadratkilometern'],
        'cm2': ['Quadratzentimeter', 'Quadratzentimetern'],
        'm3': ['Kubikmeter', 'Kubikmetern'],
        'cm3': ['Kubikzentimeter', 'Kubikzentimetern'],
        'l': ['Liter', 'Litern'],
        'ml': ['Milliliter', 'Millilitern'],
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
        'sqft': ['квадратный фут', 'квадратных фута', 'квадратных футов', 'квадратного фута'],
        'sqmi': ['квадратная миля', 'квадратные мили', 'квадратных миль', 'квадратной мили'],
        'm2': ['квадратный метр', 'квадратных метра', 'квадратных метров', 'квадратного метра'],
        'km2': ['квадратный километр', 'квадратных километра', 'квадратных километров', 'квадратного километра'],
        'cm2': ['квадратный сантиметр', 'квадратных сантиметра', 'квадратных сантиметров', 'квадратного сантиметра'],
        'cuft': ['кубический фут', 'кубических фута', 'кубических футов', 'кубического фута'],
        'cuin': ['кубический дюйм', 'кубических дюйма', 'кубических дюймов', 'кубического дюйма'],
        'm3': ['кубический метр', 'кубических метра', 'кубических метров', 'кубического метра'],
        'cm3': ['кубический сантиметр', 'кубических сантиметра', 'кубических сантиметров', 'кубического сантиметра'],
        'gal': ['галлон', 'галлона', 'галлонов', 'галлона'],
        'pint': ['пинта', 'пинты', 'пинт', 'пинты'],
        'floz': ['унция', 'унции', 'унций', 'унции'],
        'l': ['литр', 'литра', 'литров', 'литра'],
        'ml': ['миллилитр', 'миллилитра', 'миллилитров', 'миллилитра'],
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
        'sqft': ['квадратного фута', 'квадратных футов', 'квадратных футов', 'квадратного фута'],
        'sqmi': ['квадратной мили', 'квадратных миль', 'квадратных миль', 'квадратной мили'],
        'm2': ['квадратного метра', 'квадратных метров', 'квадратных метров', 'квадратного метра'],
        'km2': ['квадратного километра', 'квадратных километров', 'квадратных километров', 'квадратного километра'],
        'cm2': ['квадратного сантиметра', 'квадратных сантиметров', 'квадратных сантиметров', 'квадратного сантиметра'],
        'cuft': ['кубического фута', 'кубических футов', 'кубических футов', 'кубического фута'],
        'cuin': ['кубического дюйма', 'кубических дюймов', 'кубических дюймов', 'кубического дюйма'],
        'm3': ['кубического метра', 'кубических метров', 'кубических метров', 'кубического метра'],
        'cm3': ['кубического сантиметра', 'кубических сантиметров', 'кубических сантиметров', 'кубического сантиметра'],
        'gal': ['галлона', 'галлонов', 'галлонов', 'галлона'],
        'pint': ['пинты', 'пинт', 'пинт', 'пинты'],
        'floz': ['унции', 'унций', 'унций', 'унции'],
        'l': ['литра', 'литров', 'литров', 'литра'],
        'ml': ['миллилитра', 'миллилитров', 'миллилитров', 'миллилитра'],
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
      '': _Form(' ', {..._turkish(const ['', '', '', '', '', '', '']), ..._turkishMeasures}),
      'lik': _Form(' ', {
        ..._turkish(const ['lik', 'lik', 'lik', 'lik', 'lik', 'lik', 'lik']),
        ..._turkishMeasuresLik,
      }),
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
        'sqft': ['平方フィート'],
        'sqmi': ['平方マイル'],
        'm2': ['平方メートル'],
        'km2': ['平方キロメートル'],
        'cm2': ['平方センチメートル'],
        'cuft': ['立方フィート'],
        'cuin': ['立方インチ'],
        'm3': ['立方メートル'],
        'cm3': ['立方センチメートル'],
        'gal': ['ガロン'],
        'pint': ['パイント'],
        'floz': ['オンス'],
        'l': ['リットル'],
        'ml': ['ミリリットル'],
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
      'dir': _Form('', _korean('로', '으로', '로')),
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
        'sqft': ['平方英尺'],
        'sqmi': ['平方英里'],
        'm2': ['平方米'],
        'km2': ['平方千米'],
        'cm2': ['平方厘米'],
        'cuft': ['立方英尺'],
        'cuin': ['立方英寸'],
        'm3': ['立方米'],
        'cm3': ['立方厘米'],
        'gal': ['加仑'],
        'pint': ['品脱'],
        'floz': ['盎司'],
        'l': ['升'],
        'ml': ['毫升'],
        'sq': ['格'],
      }),
      'short': _Form('', {'ft': ['尺']}),
    },
  ),
};

const _turkishMeasures = {
  'sqft': ['fit kare'],
  'sqmi': ['mil kare'],
  'm2': ['metrekare'],
  'km2': ['kilometrekare'],
  'cm2': ['santimetrekare'],
  'cuft': ['fit küp'],
  'cuin': ['inç küp'],
  'm3': ['metreküp'],
  'cm3': ['santimetreküp'],
  'gal': ['galon'],
  'pint': ['pint'],
  'floz': ['ons'],
  'l': ['litre'],
  'ml': ['mililitre'],
};

const _turkishMeasuresLik = {
  'sqft': ['fit karelik'],
  'sqmi': ['mil karelik'],
  'm2': ['metrekarelik'],
  'km2': ['kilometrekarelik'],
  'cm2': ['santimetrekarelik'],
  'cuft': ['fit küplük'],
  'cuin': ['inç küplük'],
  'm3': ['metreküplük'],
  'cm3': ['santimetreküplük'],
  'gal': ['galonluk'],
  'pint': ['pintlik'],
  'floz': ['onsluk'],
  'l': ['litrelik'],
  'ml': ['mililitrelik'],
};
