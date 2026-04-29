# Roadmap

## v1 — MVP (atual)

- [ ] Modelos de dados completos (Character, AbilityScores, HitPoints, etc.)
- [ ] Persistência local em JSON via `path_provider`
- [ ] Assets SRD bundados (raças, classes, antecedentes, habilidades, magias, equipamentos)
- [ ] 4 modos de criação de personagem:
  - [ ] Aleatório (tudo sorteado)
  - [ ] Semi-aleatório (usuário escolhe alguns, resto é sorteado)
  - [ ] Guiado / Wizard (passo a passo com explicações, para iniciantes)
  - [ ] Manual (campos livres, para experientes)
- [ ] Ficha completa do personagem (visualização e edição)
- [ ] Lista de personagens
- [ ] Export / import via JSON (imagem não incluída no export)
- [ ] Imagem do personagem: upload de `.png`, `.jpg` ou `.webp`, salva localmente separada do JSON
- [ ] Imagem placeholder padrão para personagens sem foto

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
- [ ] Rastreador de HP em sessão (aplicar dano/cura rapidamente)
- [ ] Rastreador de spell slots em sessão

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
