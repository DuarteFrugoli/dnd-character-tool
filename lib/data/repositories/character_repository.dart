import '../datasources/local/character_local_data_source.dart';
import '../models/models.dart';

/// Ponto central de acesso a personagens no app.
/// Isola as features do datasource concreto — facilitando testes e futura
/// migração para backend remoto.
class CharacterRepository {
  CharacterRepository({CharacterLocalDataSource? dataSource})
      : _local = dataSource ?? CharacterLocalDataSource.instance;

  final CharacterLocalDataSource _local;

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
    // Remove a imagem associada, se houver.
    if (character?.imagePath != null) {
      await _local.deleteImage(character!.imagePath);
    }
  }

  // ---------------------------------------------------------------------------
  // Imagem
  // ---------------------------------------------------------------------------

  /// Salva a imagem e retorna o personagem atualizado com o novo imagePath.
  Future<Character> saveImage(Character character, String sourcePath) async {
    // Remove imagem antiga se existir.
    if (character.imagePath != null) {
      await _local.deleteImage(character.imagePath);
    }
    final fileName = await _local.saveImage(character.id, sourcePath);
    final updated = character.copyWith(imagePath: fileName, updatedAt: DateTime.now());
    await _local.save(updated);
    return updated;
  }

  /// Resolve o caminho absoluto da imagem do personagem.
  Future<String?> resolveImagePath(Character character) =>
      _local.resolveImagePath(character.imagePath);

  // ---------------------------------------------------------------------------
  // Export / Import
  // ---------------------------------------------------------------------------

  Future<String> exportToJson(Character character) =>
      _local.exportToJson(character);

  /// Importa um personagem de um JSON exportado.
  /// O personagem importado recebe um novo ID para evitar conflito caso o
  /// original já exista no dispositivo.
  Future<Character> importFromJson(String jsonString) async {
    final imported = _local.importFromJson(jsonString);

    // Verifica se já existe um personagem com o mesmo ID.
    final alreadyExists = await _local.exists(imported.id);
    final character = alreadyExists
        ? imported.copyWith(
            id: _generateId(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : imported.copyWith(updatedAt: DateTime.now());

    await _local.save(character);
    return character;
  }

  String _generateId() {
    // UUID v4 simples sem dependência extra.
    final now = DateTime.now().microsecondsSinceEpoch;
    return now.toRadixString(16).padLeft(16, '0');
  }
}
