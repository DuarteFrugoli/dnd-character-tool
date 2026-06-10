# Roadmap

---

## v1.0.0 — Lançamento público (atual)

Versão lançada na Play Store.

### Ficha — mecânicas de sessão
- [x] Rastreador de HP e spell slots em sessão
- [x] Concentração — indicador da magia ativa, aviso ao tentar empilhar
- [x] Descanso Curto / Longo — recuperar HP (HD), slots e usos de features
- [x] Death Saves — 3 sucessos / 3 falhas, reset automático ao receber cura
- [x] Saving Throws — valores calculados (mod + proficiência) sempre visíveis
- [x] Condições ativas — 15 condições do SRD com chips, descrições e persistência

### Ficha — progressão
- [x] Level up guiado — escolha de subclasse, ASI/feat, novos slots e features

### Inventário
- [x] Peso do inventário — barra de carga (STR × 15 lb)
- [x] Unidades por região — Imperial (ft/lb), Métrico (m/kg) ou Squares; padrão pelo locale

### Internacionalização
- [x] 10 idiomas (en, pt, es, fr, de, it, ja, ko, ru, zh)
- [x] Alcance de magias localizado (Self, Touch, tipos de área: sphere, cone…)
- [x] Nomes de classe na ficha de magia traduzidos
- [x] Material de componente traduzido via JSON de i18n

### Qualidade de UX
- [x] Cursor pointer nos elementos clicáveis na web
- [x] Ficha de atributos com largura máxima na web
- [x] Confirmação de descarte ao mudar de aba em modo edição

### Testes automatizados
- [x] `SpellcastingEngine`, `buildAndSave`, `CharacterRepository`

---

## v1.0.0 — Lançamento público (em andamento)

### Ficha — mecânicas de sessão
- [x] Rastreador de HP e spell slots em sessão
- [x] Concentração — indicador da magia ativa, aviso ao tentar empilhar
- [x] Descanso Curto / Longo — recuperar HP (HD), slots e usos de features
- [x] Death Saves — 3 sucessos / 3 falhas, reset automático ao receber cura
- [x] Saving Throws — valores calculados (mod + proficiência) sempre visíveis
- [x] Condições ativas — 15 condições do SRD com chips, descrições e persistência

### Ficha — progressão do personagem
- [x] Level up guiado — escolha de subclasse (se aplicável), ASI/feat, novos slots e features

### Inventário
- [x] Peso do inventário — barra de carga (STR × 15 lb) com unidades Imperial/Métrico/Squares
- [x] Unidades por região — Imperial (ft/lb), Métrico (m/kg) ou Squares configurável em Settings; padrão pelo locale

### Internacionalização
- [x] 10 idiomas (en, pt, es, fr, de, it, ja, ko, ru, zh)
- [x] Alcance de magias localizado (Self, Touch, tipos de área: sphere, cone, cube…)
- [x] Nomes de classe na ficha de magia traduzidos via i18n
- [x] Material de componente das magias traduzido via JSON de i18n
- [x] Ferramenta `patch_spell_material.py` — adiciona traduções de material sem reescrever o JSON inteiro

### Qualidade de UX
- [x] Cursor pointer nos elementos clicáveis na web (spell slots, equip/unequip, concentração, avatar)
- [x] Ficha de atributos com largura máxima na web (evita cards gigantes)
- [x] Confirmação de descarte ao mudar de aba em modo edição

### Testes automatizados
- [x] `SpellcastingEngine` — slots, DC, attack bonus por classe e nível
- [x] `buildAndSave` — fluxo de criação com armadura/CA
- [x] `CharacterRepository` — save → load → delete

---

## v1.1 — Multiclasse + Schema Versioning

### Schema versioning e migração
- [ ] Campo `schemaVersion: int` no modelo `Character` (atual = 1, multiclasse = 2)
- [ ] Badge discreto no card da lista quando `schemaVersion < atual` (ex: chip `v1` no canto inferior)
- [ ] Migração automática ao abrir o personagem — toast *"Personagem atualizado"* + salva com `schemaVersion: 2`
- [ ] Código legado removível após todos os personagens migrarem

### Multiclasse
- [ ] **Fase 1 — Modelo** — `schemaVersion: 2`; `List<CharacterClassEntry>` no `Character`; `SpellSlots` derivado; `hitDice: Map<String, int>`; `preparedSpells: Map<String, List<String>>`
- [ ] **Fase 2 — SpellcastingEngine** — tabela de slots combinados do PHB (full×1, half×0.5, third×0.33, pact separado)
- [ ] **Fase 3 — Level up wizard** — escolher qual classe sobe; adicionar nova classe (validação de pré-requisito); ASI por classe
- [ ] **Fase 4 — UI da ficha** — header "Wizard 3 / Cleric 2"; preparation separada por classe

---

## v1.2 — Mecânicas avançadas e acessibilidade

### Dados virtuais
- [ ] Toggle nas configurações para habilitar/desabilitar (desabilitado por padrão)
- [ ] Toque em atributo/perícia → rola 1d20 + modificador com animação
- [ ] Histórico da última rolagem visível na ficha

### Acessibilidade
- [ ] Tamanho de fonte configurável — Pequeno / Normal / Grande via `MediaQuery.textScaler` no root

### Companheiros e montarias
- [ ] Subficha vinculada ao personagem (relevante para Ranger, Paladin, Find Familiar)

---

## v1.3 — Notas de sessão

- [ ] Notas organizadas por sessão (título + data automática)
- [ ] Lista de sessões com preview da primeira linha
- [ ] Campo de notas livre dentro de cada sessão

---

## v2 — Ferramenta de Mestre

### Navegação
- [ ] Bottom navigation bar: **Personagens** | **NPCs**

### Gerador de NPCs
- [ ] **Geração rápida** — 1 botão → ficha completa aleatória
- [ ] **Geração com filtros** — mestre escolhe raça, classe e nível
- [ ] **Nível de importância**: Figurante (nome + AC + HP) / Secundário / Importante (ficha salva)
- [ ] Flag `isNpc: bool` no modelo `Character`

---

## v3 — Backend e social

- [ ] Backend com Supabase (conta de usuário, sync em nuvem)
- [ ] Compartilhar personagem via link
- [ ] Integração com DALL-E para gerar imagem do personagem
  - Prompt montado de `race`, `class`, aparência (`CharacterAppearance`)
  - Usuário pode editar o prompt antes de gerar
  - Imagem salva localmente como as demais

---

## Ideias futuras

- Companheiro de IA para narrar/sugerir ações durante a sessão
- Modo campanha: grupo de personagens com história compartilhada
- Bestiary — catálogo de monstros com fichas prontas
- Suporte a outros sistemas de RPG além de D&D 5e

