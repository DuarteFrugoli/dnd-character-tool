bool readBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'y':
      case 'sim':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'n':
      case 'nao':
      case 'n\u00e3o':
        return false;
    }
  }
  return defaultValue;
}
