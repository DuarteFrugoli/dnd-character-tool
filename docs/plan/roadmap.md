# Roadmap

## v1 — MVP (pronto)

- [x] Modelos de dados completos (Character, AbilityScores, HitPoints, EquipmentItem, SpellSlots, etc.)
- [x] Persistência local em JSON via `path_provider` (nativo) e `shared_preferences` (web)
- [x] Assets SRD bundados (raças, classes, subclasses, antecedentes, habilidades, magias, equipamentos, class features, itens mágicos)
- [x] Modo de criação guiado (passo a passo, 7 etapas)
- [x] Ficha do personagem — visualização (Stats, Skills, Spells, Inventory, Notes)
- [x] Rastreador de HP e spell slots em sessão
- [x] Browser de magias (busca, filtros, add/remove com confirmação, detail sheet)
- [x] Sistema de prepare-all (Cleric, Druid, Paladin, Artificer, Wizard) — lista dinâmica do SRD, long-press para desativar
- [x] Magias de subclasse always-prepared (domínios, juramentos, patronos) — `subclassSpells` no JSON + injeção no provider
- [x] Eldritch Knight / Arcane Trickster — `SpellProgressionType.third` no engine
- [x] Inventário com moedas (CP/SP/EP/GP/PP), equipar/desequipar, adicionar/remover itens
- [x] Cálculo automático de AC ao equipar armadura
- [x] Equipamento inicial do background aplicado na criação
- [x] Lista de personagens
- [x] Export / import via JSON e token (gzip + base64url)
- [x] Export / import via QR Code (geração + scanner com câmera)
- [x] Notas livres por personagem (aba Notes com CRUD)
- [x] Temas de cores
- [x] Imagem do personagem (galeria, crop 1:1, avatar na lista)
- [x] Pin e reordenação de personagens
- [x] Internacionalização (i18n): Línguas mais utilizadas

---

## v1.5 — Qualidade de vida do jogador (atual)

### Edição da ficha
- [x] Level up guiado — ao subir de nível: escolha de subclasse (se aplicável), ASI/feat, novos slots e features
- [x] Condições ativas — 15 condições do SRD com chips, descrições e persistência
- [x] Death Saves — 3 sucessos / 3 falhas, reset automático ao receber cura
- [x] Saving Throws — valores calculados (mod + proficiência) sempre visíveis
- [ ] Multiclasse
- [ ] Descanso Curto / Longo — recuperar HP (HD), slots e usos de features
- [ ] Concentração — indicador da magia ativa, aviso ao tentar empilhar
- [ ] Rolar dados diretamente na ficha (toque em atributo/perícia → resultado)

### Testes automatizados
- [x] `SpellcastingEngine` — slots, DC, attack bonus por classe e nível
- [x] `buildAndSave` — fluxo de criação com armadura/CA
- [x] `CharacterRepository` — save → load → delete

### Pequenas melhorias
- [x] Export completo como `.dndchar` (JSON + imagem embutida em base64)
- [x] Export / import `.dndchar` funcionando na web
- [x] Token de compartilhamento compatível entre mobile e web
- [ ] Peso do inventário — barra de carga (STR × 15 lb) com unidades Imperial/Métrico

---

## v2 — Ferramenta de Mestre

### Home com navegação por abas
- [ ] Bottom navigation bar: **Personagens** | **NPCs**
- [ ] Aba "Personagens": lista atual de PCs com FAB de criação
- [ ] Aba "NPCs": lista de NPCs salvos com FAB para o gerador

### Gerador de NPCs
- [ ] **Geração rápida**: 1 botão "Gerar NPC" → ficha completa aleatória (nome, raça, classe, background, atributos sorteados)
- [ ] **Geração com filtros**: mestre escolhe raça, classe e nível; o resto é sorteado
- [ ] **Nível de importância**: toggle *Figurante / Secundário / Importante*
  - Figurante: nome, raça, AC e HP — gerado e usado sem salvar
  - Secundário: ficha completa sem equipamento e magias detalhadas
  - Importante: ficha completa salva na lista de NPCs
- [ ] Flag `isNpc: bool` no modelo `Character` para distinguir PCs de NPCs internamente
- [ ] NPCs figurantes têm opção de "Salvar" ou "Descartar" após geração

---

## v3 — Backend e social

- [ ] Backend com Supabase (conta de usuário, sync em nuvem)
- [ ] Compartilhar personagem via link
- [ ] Integração com a API da OpenAI (DALL-E) para gerar imagem do personagem
  - Prompt montado automaticamente a partir de: `race`, `characterClass`, `CharacterAppearance` (olhos, cabelo, pele, etc.)
  - Usuário pode editar o prompt antes de gerar
  - Imagem gerada salva localmente como as demais

---

## Ideias futuras (sem versão definida)

- Companheiro de IA para narrar/sugerir ações durante a sessão
- Modo campanha: grupo de personagens com história compartilhada
- Bestiary / catálogo de monstros e NPCs com fichas prontas
- Sistema de notas de sessão vinculadas ao personagem
- Suporte a outros sistemas de RPG além de D&D 5e
