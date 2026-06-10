# Roadmap

---

## v0.3.5 — Open Beta (atual)

Versão enviada ao open beta da Play Store. Todas as features abaixo estão completas.

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
- [ ] **Multiclasse** — `List<CharacterClassEntry>` no modelo; slots combinados pela tabela PHB; level up com escolha de classe; preparation por classe separada; HD por classe

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

## v1.1 — Mecânicas avançadas

### Dados virtuais
- [ ] Toggle nas configurações para habilitar/desabilitar (desabilitado por padrão)
- [ ] Toque em atributo/perícia → rola 1d20 + modificador com animação
- [ ] Histórico da última rolagem visível na ficha

### Acessibilidade
- [ ] Tamanho de fonte configurável — Pequeno / Normal / Grande via `MediaQuery.textScaler` no root

### Companheiros e montarias
- [ ] Subficha vinculada ao personagem (relevante para Ranger, Paladin, Find Familiar)

---

## v1.2 — Notas de sessão

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

---

## Multiclasse — plano de implementação

### Fase 1 — Modelo de dados (sem retrocompat)
```dart
class CharacterClassEntry {
  final String className;
  final int level;
  final String? subclass;
}
// Character.classes: List<CharacterClassEntry>
// Character.get totalLevel => classes.fold(0, (s, e) => s + e.level)
```
- `SpellSlots` passa a ser derivado (calculado), não armazenado
- `hitDice` vira `Map<String, int>` — ex: `{ 'd8': 3, 'd6': 2 }`
- `preparedSpells` vira `Map<String, List<String>>` — chaveado por classe

### Fase 2 — SpellcastingEngine
- Tabela de slots combinados do PHB (full=1×, half=0.5×, third=0.33×, pact=separado)
- `SpellProgressionType` já existe — só precisa agregar por `classes`

### Fase 3 — Level up wizard
- Passo "escolher qual classe sobe" (ou adicionar nova com validação de pré-requisito de atributo)
- Subclasse por classe independente
- ASI por classe (a cada 4 níveis na maioria)

### Fase 4 — UI da ficha
- Header: "Wizard 3 / Cleric 2" em vez de "Wizard 5"
- Slots combinados exibidos normalmente
- Spell preparation separada por classe com contadores independentes

