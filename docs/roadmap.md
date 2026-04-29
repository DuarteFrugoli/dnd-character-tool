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

## v1.5 — Qualidade de vida

- [ ] Export completo como `.zip` (JSON + imagem do personagem juntos)
- [ ] Imagens de exemplo bundadas para NPCs e equipamentos base
- [ ] Tema visual customizado (cores, tipografia inspirada em D&D)
- [ ] Rolar dados diretamente na ficha (animação de dado)
- [ ] Rastreador de HP em sessão (aplicar dano/cura rapidamente)
- [ ] Rastreador de spell slots em sessão

---

## v2 — Backend e social

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
