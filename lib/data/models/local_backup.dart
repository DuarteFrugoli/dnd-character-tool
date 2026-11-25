class LocalBackupInfo {
  const LocalBackupInfo({
    required this.id,
    required this.createdAt,
    required this.characterCount,
    this.sequence = 0,
  });

  final String id;
  final DateTime createdAt;
  final int characterCount;
  final int sequence;

  static void validateId(String id) {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id)) {
      throw const FormatException('invalid_local_backup_id');
    }
  }

  factory LocalBackupInfo.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    validateId(id);
    final count = json['characterCount'] as int;
    final sequence = json['sequence'] as int? ?? 0;
    if (count < 0 || sequence < 0) {
      throw const FormatException('invalid_local_backup_count');
    }
    return LocalBackupInfo(
      id: id,
      createdAt: DateTime.parse(json['createdAt'] as String),
      characterCount: count,
      sequence: sequence,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'characterCount': characterCount,
    'sequence': sequence,
  };
}
