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

### Provider de rascunho
- [ ] `CharacterDraftNotifier` — estado mutável do personagem em construção, limpo ao cancelar
- [ ] Rota `/create` com parâmetro de modo (`?mode=guided`)

### Fluxo de criação — modo guiado (7 etapas)

**Etapa 1 — Classe**
- [ ] Lista das 12 classes com hit die, saving throws e resumo de proficiências
- [ ] Seleção persiste no draft

**Etapa 2 — Raça**
- [ ] Lista das 9 raças SRD com bônus de atributo e traits
- [ ] Se a raça tiver subraça, exibir segundo passo de seleção na mesma tela

**Etapa 3 — Antecedente (Background)**
- [ ] Lista dos 13 antecedentes com descrição da feature
- [ ] Perícias fixas do background aplicadas automaticamente ao draft

**Etapa 4 — Perícias**
- [ ] Exibir perícias fixas do background (somente leitura)
- [ ] Perícias fixas da raça (ex: Elfo → Percepção) aplicadas automaticamente
- [ ] Escolhas da classe: N perícias dentro da lista permitida por classe
- [ ] Escolhas extras da raça (ex: Meio-Elfo escolhe 2 quaisquer)

**Etapa 5 — Atributos**
- [ ] Usuário escolhe o método: **Standard Array** `[15,14,13,12,10,8]` ou **Point Buy** (27 pts, base 8)
- [ ] Interface de distribuição dos valores nos 6 atributos
- [ ] Toggle: "Aplicar bônus raciais automaticamente (PHB)" vs "Distribuir livremente (Tasha's / BG3)"
- [ ] Cálculo automático dos modificadores em tempo real

**Etapa 6 — Nome**
- [ ] Campos: nome do personagem e nome do jogador
- [ ] Botão "Definir depois" — preenche com placeholder e segue para revisão

**Etapa 7 — Revisão**
- [ ] Resumo de todas as escolhas (classe, raça, background, perícias, atributos, nome)
- [ ] Exibir HP máximo calculado: `hitDie + mod CON`
- [ ] Botão "Criar Personagem" → salva via `CharacterRepository.save()` e navega para a lista

### Navegação e UX
- [ ] Widget `StepIndicator` com barra de progresso por etapa
- [ ] Botões "Voltar" e "Continuar" com validação por etapa
- [ ] Botão "Cancelar" com diálogo de confirmação antes de descartar o rascunho

### Cálculos automáticos ao salvar
- [ ] `proficiencyBonus` = 2 (nível 1, fixo)
- [ ] `hitPoints.maximum` = hitDie + mod CON
- [ ] `savingThrowProficiencies` da classe
- [ ] `skillProficiencies` consolidadas (background + raça + escolhas da classe)
- [ ] `armorClass` base = 10 + mod DEX

---

## Fora do escopo desta sprint
- Modo aleatório, semi-aleatório e manual (Sprint 3)
- Ficha detalhada / edição de personagem existente
- Seleção de equipamento e magias iniciais (listas vazias por ora)
- Foto do personagem
- Export / import

