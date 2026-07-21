import 'dart:math' as math;

import '../datasources/local/character_local_data_source.dart';
import '../datasources/srd/srd_data_source.dart';
import '../migrations/character_migration.dart';
import '../migrations/character_migration_runner.dart';
import '../models/models.dart';

/// Ponto central de acesso a personagens no app.
/// Isola as features do datasource concreto — facilitando testes e futura
/// migração para backend remoto.
class CharacterRepository {
  CharacterRepository({
    CharacterLocalDataSource? dataSource,
    SrdDataSource? srdDataSource,
    CharacterMigrationRunner? migrationRunner,
  })  : _local = dataSource ?? CharacterLocalDataSource.instance,
        _srd = srdDataSource ?? SrdDataSource.instance,
        _migrationRunner = migrationRunner ?? CharacterMigrationRunner();

  final CharacterLocalDataSource _local;
  final SrdDataSource _srd;
  final CharacterMigrationRunner _migrationRunner;

  // ---------------------------------------------------------------------------
  // Leitura
  // ---------------------------------------------------------------------------

  Future<List<Character>> getAll() => _local.loadAll();

  Future<Character?> getById(String id) => _local.loadById(id);

  // ---------------------------------------------------------------------------
  // Escrita
  // ---------------------------------------------------------------------------

  /// Cria ou atualiza um personagem.
  Future<Character> save(Character character) async {
    final updated = character.copyWith(updatedAt: DateTime.now());
    await _local.save(updated);
    return updated;
  }

  Future<void> delete(String id) async {
    final character = await _local.loadById(id);
    await _local.delete(id);
    await _local.deleteImage(character?.imagePath);
  }

  // ---------------------------------------------------------------------------
  // Imagem
  // ---------------------------------------------------------------------------

  /// Salva a imagem e retorna o personagem atualizado com o novo imagePath.
  Future<Character> saveImage(Character character, String sourcePath) async {
    final fileName = await _local.saveImage(character.id, sourcePath);
    if (fileName == null) return character;

    final updated = character.copyWith(
      imagePath: fileName,
      updatedAt: DateTime.now(),
    );
    await _local.save(updated);
    if (character.imagePath != fileName) {
      await _local.deleteImage(character.imagePath);
    }
    return updated;
  }

  /// Remove a imagem do personagem e retorna o personagem atualizado sem imagePath.
  Future<Character> removeImage(Character character) async {
    await _local.deleteImage(character.imagePath);
    final updated = character.copyWith(
      clearImagePath: true,
      updatedAt: DateTime.now(),
    );
    await _local.save(updated);
    return updated;
  }

  /// Resolve o caminho absoluto da imagem do personagem.
  Future<String?> resolveImagePath(Character character) =>
      _local.resolveImagePath(character.imagePath);

  // ---------------------------------------------------------------------------
  // Maintenance / Migrations
  // ---------------------------------------------------------------------------

  Future<CharacterMigrationBatchReport> previewMigrations() async {
    final characters = await _local.loadAll();
    final context = await _migrationContext();
    return _migrationRunner.preview(characters, context);
  }

  Future<CharacterMigrationBatchReport> applyMigrations() async {
    final characters = await _local.loadAll();
    final context = await _migrationContext();
    final report = _migrationRunner.preview(characters, context);

    for (final entry in report.characters) {
      if (!entry.needsMigration) continue;
      await _local.save(entry.character);
    }

    return report;
  }

  Future<CharacterMigrationContext> _migrationContext() async {
    return CharacterMigrationContext(
      itemsByName: await _srd.getItems(),
    );
  }

  // ---------------------------------------------------------------------------
  // Export / Import
  // ---------------------------------------------------------------------------

  Future<String> exportToJson(Character character) =>
      _local.exportToJson(character);

  Future<String> exportToFileJson(Character character) =>
      _local.exportToFileJson(character);

  Future<String> exportBackupToFileJson() =>
      _local.exportBackupToFileJson();

  /// Importa um personagem de um JSON exportado.
  /// O personagem importado *sempre* recebe um novo ID para garantir que o ID
  /// persistido seja gerado localmente (previne path traversal e conflitos).
  Future<Character> importFromJson(String jsonString) async {
    final imported = _local.importFromJson(jsonString);

    final character = imported.copyWith(
      id: _generateId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _local.save(character);
    return character;
  }

  Future<Character> importFromDndCharFile(String fileJson) async {
    final id = _generateId();
    final imported = await _local.importFromDndCharFile(
      fileJson,
      imageOwnerId: id,
    );

    final character = imported.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _local.save(character);
    return character;
  }

  Future<List<Character>> importBackupFromFileJson(String fileJson) async {
    final entries = _local.backupEntriesFromFileJson(fileJson);
    final importedCharacters = <Character>[];

    for (final entry in entries) {
      final id = _generateId();
      final imported = await _local.importFromDndCharPayload(
        entry,
        imageOwnerId: id,
      );
      final now = DateTime.now();
      final character = imported.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
      );

      await _local.save(character);
      importedCharacters.add(character);
    }

    return importedCharacters;
  }

  String _generateId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rnd = math.Random().nextInt(0xFFFF);
    return '${now.toRadixString(16).padLeft(16, '0')}${rnd.toRadixString(16).padLeft(4, '0')}';
  }
}
