## v1 — essencial (fazer agora)

### modos de criação
- [x] modo guiado (wizard passo a passo completo)
- [ ] **modo aleatório** ← próximo passo
- [ ] modo semi-aleatório (usuário escolhe raça/classe, resto é sorteado)
- [ ] modo manual (campos livres, sem cálculos automáticos)

### ficha
- [x] stats, skills, magias, inventário, anotações
- [x] HP temporário (drena temp antes do real, dialog com escudo)
- [x] escolha de idiomas na criação guiada
- [ ] edição de ficha existente (atributos, raça, classe, etc.)

## v1.1 — após feedback inicial

- [ ] perguntar para possíveis usuários se gostaram do produto
- [ ] colocar imagens nos personagens (model já tem `imagePath`)

## médio prazo

- [ ] geração de NPCs para mestres (flag `isNpc` no model)
- [ ] melhorar o levelup no modo guiado para iniciantes
- [ ] permitir levelup com características customizadas
- [ ] criar classe/subclasse/raça/itens customizados

## longo prazo / dependem de orçamento

- [ ] salvar na nuvem (Supabase)
- [ ] integração DALL-E para gerar imagem do personagem pelo app

## bugs / infra

- [ ] consertar regra sem atributo por raça (ex: resistências sem ability score)
- [ ] GitHub Actions: deploy automático no GitHub Pages ao atualizar main