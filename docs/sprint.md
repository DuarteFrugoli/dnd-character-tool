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
- [x] `CharacterDraftNotifier` — estado mutável do personagem em construção, limpo ao cancelar
- [x] Rota `/create` com parâmetro de modo (`?mode=guided`)

### Fluxo de criação — modo guiado (7 etapas)

**Etapa 1 — Classe**
- [x] Lista das 12 classes com hit die, saving throws e resumo de proficiências
- [x] Seleção persiste no draft

**Etapa 2 — Raça**
- [x] Lista das 9 raças SRD com bônus de atributo e traits
- [x] Se a raça tiver subraça, exibir segundo passo de seleção na mesma tela

**Etapa 3 — Antecedente (Background)**
- [x] Lista dos 13 antecedentes com descrição da feature
- [x] Perícias fixas do background aplicadas automaticamente ao draft

**Etapa 4 — Perícias**
- [x] Exibir perícias fixas do background (somente leitura)
- [x] Escolhas da classe: N perícias dentro da lista permitida por classe

**Etapa 5 — Atributos**
- [x] Usuário escolhe o método: **Standard Array** `[15,14,13,12,10,8]` ou **Point Buy** (27 pts, base 8)
- [x] Interface de distribuição dos valores nos 6 atributos
- [x] Toggle: "Aplicar bônus raciais automaticamente (PHB)" vs "Distribuir livremente (Tasha's / BG3)"
- [x] Cálculo automático dos modificadores em tempo real

**Etapa 6 — Nome**
- [x] Campos: nome do personagem e nome do jogador
- [x] Botão "Definir depois" — preenche com placeholder e segue para revisão

**Etapa 7 — Revisão**
- [x] Resumo de todas as escolhas (classe, raça, background, perícias, atributos, nome)
- [x] Exibir HP máximo calculado: `hitDie + mod CON`
- [x] Botão "Criar Personagem" → salva via `CharacterRepository.save()` e navega para a lista

### Navegação e UX
- [x] Widget `StepIndicator` com barra de progresso por etapa
- [x] Botões "Voltar" e "Continuar" com validação por etapa
- [x] Botão "Cancelar" com diálogo de confirmação antes de descartar o rascunho

### Cálculos automáticos ao salvar
- [x] `proficiencyBonus` = 2 (nível 1, fixo)
- [x] `hitPoints.maximum` = hitDie + mod CON
- [x] `savingThrowProficiencies` da classe
- [x] `skillProficiencies` consolidadas (background + escolhas da classe)
- [x] `armorClass` base = 10 + mod DEX

---

## Fora do escopo desta sprint
- Modo aleatório, semi-aleatório e manual (Sprint 3)
- Ficha detalhada / edição de personagem existente
- Seleção de equipamento e magias iniciais (listas vazias por ora)
- Foto do personagem
- Export / import

---

# Sprint 3 — Ficha do personagem (planejada)

Objetivo: após criar um personagem, o jogador consegue ver e editar sua ficha completa. Inclui navegação da lista para a ficha e rastreamento de HP/spell slots em sessão.

---

## Tarefas

### Navegação
- [x] Rota `/character/:id` no router
- [x] `onTap` do card na lista navega para `/character/:id`

### Tela de ficha (`CharacterDetailScreen`)
- [x] Carrega o personagem por ID via `CharacterRepository`
- [x] Layout com abas:
  - [x] **Stats** — Identidade, HP tracker, Combat (AC, speed, iniciativa, prof bonus, passive perc), Atributos, Saving throws
  - [x] **Skills** — lista das 18 perícias com ícone de proficiência/expertise e valor final
  - [x] **Spells** — spell slots por nível com círculos clicáveis, lista de magias conhecidas
  - [x] **Notes** — personality traits, ideals, bonds, flaws, backstory, features

### Rastreador de HP (sessão)
- [x] Botões `Damage` e `Heal` com campo de quantidade
- [x] HP temporário exibido como chip
- [x] Indicador visual de morte (HP ≤ 0 → "Unconscious / Dying")

### Rastreador de spell slots (sessão)
- [x] Círculos clicáveis por nível (tap para usar, tap novamente para restaurar)
- [x] Botão "Long Rest" — restaura HP máximo e todos os slots

### Edição básica
- [x] Editar nome do personagem (modal)
- [x] Editar nível (recalcula proficiency bonus automaticamente)
- [x] Salvar alterações via `CharacterRepository.save()`

---

## Fora do escopo desta sprint
- Edição completa da ficha (atributos, raça, classe, etc.)
- Foto do personagem
- Export / import
- i18n

---

# Sprint 4 — Inventário & Equipamentos (planejada)

Objetivo: o jogador consegue gerenciar itens, armas, armaduras e moedas do personagem na ficha. O equipamento inicial do background é aplicado automaticamente ao criar.

---

## Tarefas

### Aba Inventory na ficha
- [x] Nova aba **Inventory** no `CharacterDetailScreen` (entre Spells e Notes)
- [x] Listar itens separados em seções **Equipped** e **Carried**
- [x] Ícone de status: equipado (escudo preenchido) ou carregado (backpack)
- [x] Toggle para equipar/desequipar item (tap no ícone)
- [x] Remover item (botão lixeira)

### Adicionar itens
- [x] Botão FAB "+" abre dialog de item custom (nome, categoria, quantidade, descrição)
- [ ] Aba "SRD" no dialog: busca/filtra itens de `equipment.json` e `magic_items.json`

### Cálculo de AC com armadura
- [ ] Quando armadura é equipada, recalcular AC automaticamente:
  - Couro: 11 + DEX mod
  - Cota de malha: 13 + DEX mod (max +2)
  - Meia-placa: 15 + DEX mod (max +2)
  - Placa completa: 18 (sem DEX)
  - Sem armadura: 10 + DEX mod
- [ ] Provider atualiza `character.armorClass` ao equipar/desequipar armadura
- [ ] Exibir na aba Stats qual armadura está sendo usada

### Moedas
- [x] Campo de moedas na aba Inventory: CP / SP / EP / GP / PP
- [x] Campos editáveis inline (salva ao perder foco)
- [x] Persistido no modelo `Character` (novo campo `currency: Map<String, int>`)

### Equipamento inicial do background
- [ ] Campo `startingEquipment: List<String>` em `SrdBackground` (parsear do JSON)
- [ ] Ao finalizar criação (buildAndSave), adicionar itens do background como `EquipmentItem` na lista do personagem

### Dados SRD de suporte
- [x] `class_features.json` — features por nível para todas as 12 classes
- [x] `magic_items.json` — itens mágicos SRD (poções, wondrous items, armas/armaduras +1/+2/+3)
- [x] Seção `gear` adicionada a `equipment.json` (~65 itens: adventuring gear, containers, kits, munição, etc.)
- [x] Assets registrados no `pubspec.yaml`

### Provider
- [x] `addEquipmentItem(EquipmentItem)` em `CharacterDetailNotifier`
- [x] `removeEquipmentItem(String itemName)` em `CharacterDetailNotifier`
- [x] `toggleEquipped(String itemName)` em `CharacterDetailNotifier`
- [x] `updateCurrency(Map<String, int>)` em `CharacterDetailNotifier`

---

## Fora do escopo desta sprint
- Peso total / capacidade de carga (strength × 15)
- Economia de loja / compra e venda
- Conjuração de itens mágicos
- i18n

