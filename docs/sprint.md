# Sprint 1 — Fundação (em andamento)

Objetivo: ter o app rodando com persistência local funcional e dados do SRD disponíveis.

---

## Tarefas

### Modelos de dados
- [x] `AbilityScores`
- [x] `HitPoints`
- [x] `CharacterAppearance`
- [x] `CharacterPersonality`
- [x] `EquipmentItem`
- [x] `SpellSlots` / `KnownSpell`
- [x] `Character` (modelo principal)
- [x] Geração de `fromJson`/`toJson` via `build_runner`

### Persistência local
- [x] `CharacterLocalDataSource` — salvar/carregar/deletar JSON no disco
- [x] `CharacterRepository` — abstração sobre o datasource
- [x] Tratamento de imagem do personagem (salvar arquivo separado, referenciar por caminho)

### Assets SRD
- [x] `races.json` — 9 raças SRD com subraças e bônus de atributo
- [x] `classes.json` — 12 classes com hit die, saving throws, proficiências
- [x] `backgrounds.json` — 13 antecedentes com proficiências e equipamento inicial
- [x] `skills.json` — 18 habilidades com atributo base
- [x] `spells.json` — 20 cantrips + ~30 spells nível 1-3 do SRD
- [x] `equipment.json` — armas simples/marciais e armaduras completas
- [x] `SrdDataSource` — serviço que lê e parseia esses JSONs

### Infraestrutura do app
- [x] Configurar Riverpod (`ProviderScope` no `main.dart`)
- [x] Configurar `go_router` com rotas básicas
- [x] Tela inicial (lista de personagens vazia com botão de criar)

---

## Fora do escopo desta sprint
- Modos de criação de personagem
- Ficha detalhada do personagem
- Export / import
- UI visual final (tema, cores)
