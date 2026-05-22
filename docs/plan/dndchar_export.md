# Export de arquivo `.dndchar` (com imagem)

## Objetivo

Permitir exportar um personagem **completo** — incluindo a foto — como um arquivo `.dndchar`
que pode ser compartilhado via WhatsApp, Drive, AirDrop, etc. e reimportado em outro dispositivo.

O token continua existindo para compartilhamento rápido de stats entre jogadores.
O arquivo `.dndchar` serve para backup e migração de dispositivo.

---

## Formato do arquivo

Extensão: `.dndchar`  
Conteúdo: JSON idêntico ao export atual + campos opcionais de imagem.

```json
{
  "version": "1.0",
  "exportedAt": "2026-05-21T10:00:00Z",
  "imageData": "<base64 dos bytes da imagem>",
  "imageMimeType": "image/jpeg",
  "character": { ... }
}
```

- `imageData` e `imageMimeType` são `null` se o personagem não tiver foto.
- `character` é idêntico ao JSON atual (sem `imagePath`, que é local).
- O arquivo é texto puro — pode ser aberto em qualquer editor.

---

## Interface

### Problema atual

O dialog de export tem 2 opções (Token, JSON). Adicionar o arquivo como uma 3ª seção no
mesmo estilo seria confuso — a semântica é diferente das outras duas.

### Proposta: separar por semântica

Dividir o dialog em dois grupos com cabeçalho claro:

```
┌─ Exportar "Aragorn" ────────────────────────────┐
│                                                 │
│  Compartilhamento rápido                        │  ← labelLarge
│  Sem imagem — para compartilhar stats           │  ← caption
│                                                 │
│  [token box ─────────────────────────────────]  │
│  [● Copiar token]                               │
│                                                 │
│  ───────────────────────────────────────────    │
│                                                 │
│  Arquivo completo                               │  ← labelLarge
│  Inclui a foto do personagem                   │  ← caption
│                                                 │
│  [↑ Exportar .dndchar]                         │  ← FilledButton.icon
│                                                 │
│  ▸ Mostrar JSON                                 │  ← expandable (mantém)
│                                                 │
│                              [Fechar]           │
└─────────────────────────────────────────────────┘
```

**Por que essa estrutura:**
- O usuário entende imediatamente qual opção serve para cada caso
- "Compartilhamento rápido" → Token (sem imagem, instantâneo)
- "Arquivo completo" → `.dndchar` (com imagem, salva e compartilha)
- O JSON expandível fica como opção técnica/avançada, sem destaque

### Ícone sugerido
`Icons.ios_share` (universal para "compartilhar arquivo") ou `Icons.upload_file`.

---

## Implementação — Export

### 1. `character_local_data_source.dart`

Adicionar método `exportToFileJson(Character character)` que lê a imagem e inclui no payload:

```dart
Future<String> exportToFileJson(Character character) async {
  String? imageData;
  String? imageMimeType;

  if (character.imagePath != null) {
    final file = File(character.imagePath!);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      imageData = base64Encode(bytes);
      // detectar por extensão
      final ext = character.imagePath!.split('.').last.toLowerCase();
      imageMimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
    }
  }

  final payload = {
    'version': '1.0',
    'exportedAt': DateTime.now().toIso8601String(),
    if (imageData != null) 'imageData': imageData,
    if (imageMimeType != null) 'imageMimeType': imageMimeType,
    'character': character.copyWith(clearImagePath: true).toJson(),
  };
  return const JsonEncoder.withIndent('  ').convert(payload);
}
```

### 2. `character_repository.dart`

Expor o novo método:

```dart
Future<String> exportToFileJson(Character character) =>
    _local.exportToFileJson(character);
```

### 3. `character_list_provider.dart`

```dart
Future<String> exportCharacterToFile(Character character) {
  return ref.read(characterRepositoryProvider).exportToFileJson(character);
}
```

### 4. `character_list_screen.dart` — `exportCharacter()`

Computar o fileJson junto com o token (ambos em isolates):

```dart
Future<void> exportCharacter() async {
  final results = await Future.wait([
    ref.read(characterListProvider.notifier).exportCharacter(character),
    ref.read(characterListProvider.notifier).exportCharacterToFile(character),
  ]);
  final json = results[0];
  final fileJson = results[1];
  final token = await compute(_buildToken, json);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => _ExportDialog(
      characterName: character.name,
      token: token,
      json: json,
      fileJson: fileJson,
    ),
  );
}
```

### 5. `_ExportDialog` — botão de compartilhamento

O botão "Exportar .dndchar" executa o seguinte no `onPressed`:

```dart
Future<void> _shareFile(BuildContext ctx) async {
  final dir = await getTemporaryDirectory();
  final safeName = widget.characterName.replaceAll(RegExp(r'[^\w]'), '_');
  final file = File('${dir.path}/$safeName.dndchar');
  await file.writeAsString(widget.fileJson);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'application/octet-stream')],
      subject: widget.characterName,
    ),
  );
}
```

---

## Implementação — Import (fase futura)

Quando o usuário receber um `.dndchar` e quiser importar:

1. Adicionar aba/botão "Importar arquivo" no `_ImportDialog`
2. Usar `file_picker` filtrando por extensão `dndchar`
3. Ler o JSON, extrair `imageData`
4. Decodificar base64 e salvar a imagem em `getApplicationDocumentsDirectory()`
5. Chamar `importFromJson()` com o `character` já ajustado com o `imagePath` local

---

## Checklist

### Export
- [ ] `exportToFileJson()` no data source
- [ ] Expor no repository e provider
- [ ] Computar `fileJson` em paralelo com `json` em `exportCharacter()`
- [ ] Passar `fileJson` para `_ExportDialog`
- [ ] Adicionar `_shareFile()` no `_ExportDialogState`
- [ ] Reestruturar UI do dialog (dois grupos)
- [ ] Localizar strings novas (exportar arquivo, caption de cada grupo)
- [ ] `flutter analyze` sem erros

### Import (fase futura)
- [ ] Aba "Arquivo" no `_ImportDialog`
- [ ] `file_picker` filtra `.dndchar`
- [ ] Extrai e salva imagem localmente
- [ ] Integra com `importFromJson()`
