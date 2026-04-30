/// Interface de armazenamento + factory stub para plataformas não reconhecidas.
/// O arquivo correto é selecionado em tempo de compilação via importação condicional.
abstract class StorageBackend {
  // ---- Personagens ----
  Future<List<Map<String, dynamic>>> loadAllCharacters();
  Future<Map<String, dynamic>?> loadCharacter(String id);
  Future<void> saveCharacter(String id, Map<String, dynamic> json);
  Future<void> deleteCharacter(String id);
  Future<bool> characterExists(String id);

  // ---- Imagens ----
  /// Persiste a imagem e retorna o nome do arquivo salvo, ou null se não suportado.
  Future<String?> saveImage(String characterId, String sourcePath);

  /// Resolve o nome do arquivo para o caminho absoluto (ou null se não encontrado/suportado).
  Future<String?> resolveImagePath(String? fileName);

  Future<void> deleteImage(String? fileName);
}

StorageBackend createStorageBackend() =>
    throw UnsupportedError('Plataforma não suportada para storage.');
