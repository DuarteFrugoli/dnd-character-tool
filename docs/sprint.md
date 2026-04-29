# Sprint 1 — Fundação (concluída)

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

---

# Sprint 2 — Criação de personagem (planejada)

Objetivo: permitir criar um personagem completo do zero usando o modo guiado (passo a passo). Os demais modos (aleatório, semi-aleatório e manual) virão em seguida, reaproveitando a mesma estrutura.

---

## Tarefas

### Fluxo de criação — modo guiado (`guided`)
O usuário avança por etapas obrigatórias, sendo guiado com as opções do SRD. Ao final, o personagem é salvo localmente.

- [ ] Rota `/create` com parâmetro de modo (`?mode=guided`)
- [ ] Provider `CharacterDraftNotifier` — estado mutável do personagem em construção
- [ ] **Etapa 1 — Nome e jogador**: campos de texto livres
- [ ] **Etapa 2 — Raça**: lista das 9 raças SRD; se houver subraça, segundo passo de seleção
- [ ] **Etapa 3 — Classe**: lista das 12 classes com hit die e resumo de proficiências
- [ ] **Etapa 4 — Antecedente (Background)**: lista dos 13 antecedentes com descrição da feature
- [ ] **Etapa 5 — Atributos (Standard Array)**: distribuição fixa `[15, 14, 13, 12, 10, 8]` nos 6 atributos com drag-and-drop ou dropdowns
- [ ] **Etapa 6 — Revisão**: resumo de todas as escolhas com botão "Criar Personagem"
- [ ] Ao confirmar: salvar via `CharacterRepository.save()` e navegar para a lista

### Navegação e UX
- [ ] Widget de barra de progresso por etapa (`StepIndicator`)
- [ ] Botões "Voltar" e "Continuar" com validação por etapa
- [ ] Botão "Cancelar" com confirmação antes de descartar o rascunho

### Ajustes derivados de raça/classe
- [ ] Aplicar bônus de atributo da raça automaticamente na revisão
- [ ] Calcular `proficiencyBonus` (sempre 2 no nível 1)
- [ ] Calcular `hitPoints` máximo no nível 1: `hitDie + modificador CON`
- [ ] Popular `savingThrowProficiencies` e `skillProficiencies` padrão da classe e antecedente

---

## Fora do escopo desta sprint
- Modo aleatório, semi-aleatório e manual (Sprint 3)
- Ficha detalhada / edição de personagem existente
- Seleção de equipamento e magias iniciais (simplificado: listas vazias por ora)
- Foto do personagem
- Export / import

