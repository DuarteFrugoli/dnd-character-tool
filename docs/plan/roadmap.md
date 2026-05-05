# Roadmap

## v1 — MVP (atual)

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
- [ ] Internacionalização (i18n): Português e Inglês

---

## v1.5 — Ferramenta de Mestre

A mesma base de modelos e modos de criação reutilizada para geração de NPCs.

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

## v2 — Qualidade de vida

- [ ] Export completo como `.zip` (JSON + imagem do personagem juntos)
- [ ] Imagens de exemplo bundadas para NPCs e equipamentos base
- [ ] Tema visual customizado (cores, tipografia inspirada em D&D)
- [ ] Rolar dados diretamente na ficha (animação de dado)
- [ ] **Modo aleatório de criação** — revisitar quando definida a questão de granularidade (o quão aleatório = ainda jogável?)
- [ ] Edição completa da ficha (raça, subraça e classe)

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
