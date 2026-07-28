# Roadmap

Este documento resume a direcao do app por versao. Ele nao substitui o
`CHANGELOG.md`: aqui entram apenas os blocos grandes de produto e arquitetura.

---

## Serie 1.x - Fundacao do app

### 1.0.0 - Ficha jogavel em mesa
- [x] Rastreamento de HP, HP temporario, death saves, inspiracao e condicoes.
- [x] Concentração de magias com aviso ao tentar manter duas magias.
- [x] Descanso curto e longo com recuperacao de HP, hit dice, slots e recursos.
- [x] Peso do inventario, capacidade de carga e sistema de unidades.
- [x] Internacionalizacao de interface, magias, unidades e termos principais.
- [x] Ajustes de UX para web e protecao contra descarte acidental de edicoes.

### 1.0.1 - Foto e level up de Warlock
- [x] Visualizador de foto com zoom/pan.
- [x] Salvar foto na galeria/download.
- [x] Troca de magia dedicada para Warlock no level up.

### 1.0.2 - CA e ferramentas
- [x] Calculo compartilhado de Armor Class.
- [x] Defesa Sem Armadura correta para Barbaro e Monge.
- [x] Gerenciamento de proficiencias de ferramentas na aba Habilidades.

### 1.0.3 - Inventario customizado e subclasses magicas
- [x] Formulario de item customizado por tipo mecanico.
- [x] Itens equipaveis genericos e containers como tipos de item.
- [x] Detalhes completos de item ao tocar no inventario.
- [x] Regras de magia para Eldritch Knight e Arcane Trickster.
- [x] Correcoes de cantrips/magias no level up.

### 1.0.4 - Feature Choices
- [x] Sistema de escolhas em features, racial traits e feats.
- [x] Escolhas obrigatorias na criacao e no level up.
- [x] Visualizacao e edicao posterior das escolhas na aba Habilidades.
- [x] Descricoes localizadas para opcoes como Fighting Style e manobras.
- [x] Listas separadas para magias restritas/livres de Eldritch Knight e
      Arcane Trickster.

### 1.0.5 - Web, backups, migracoes e recursos de features
- [x] Backup/importacao `.dndbackup` para todos os personagens.
- [x] Manutencao de personagens com migracoes versionadas acionadas pelas
      Configuracoes.
- [x] Formato `.dndchar` como caminho principal de compartilhamento individual.
- [x] IndexedDB na web para personagens e imagens.
- [x] Fallback de rotas para GitHub Pages.
- [x] Usos de features e recursos por descanso na aba Habilidades.
- [x] Humano Variante e regra de Tasha revisados na criacao.
- [x] Kits/packs de equipamento inicial expandidos para itens individuais.
- [x] Containers funcionais no inventario, sem container dentro de container.

### 1.0.6 - Notas e ordenacao escalavel
- [x] Tags coloridas em notas.
- [x] Busca por titulo, conteudo e tags.
- [x] Fixar notas importantes.
- [x] Reordenacao escalavel de notas e personagens com alca de arrastar.
- [x] Ordem explicita persistida em notas e personagens.

### 1.1.0 - Inventario escalavel, performance e cobertura de testes
- [x] Busca global ao adicionar item, sem depender da categoria escolhida.
- [x] Munições de pacote aparecem sem sufixo SRD como `(20)`.
- [x] Munição zerada permanece no inventario.
- [x] Reordenacao de itens, munições e containers no inventario.
- [x] Acoes secundarias de inventario movidas para menu de tres pontos.
- [x] Containers/mochilas guardam itens, mostram conteudo e respeitam a regra
      atual de nao guardar container dentro de container.
- [x] Ao excluir container com conteudo, o app permite cancelar, mover os itens
      para o inventario ou excluir tudo junto.
- [x] Operacoes puras de inventario para adicionar, remover, equipar, mover,
      reordenar e ajustar quantidade.
- [x] Snapshot dedicado para secoes, containers, conteudos e peso total.
- [x] Conteudo de containers aberto em bottom sheet, sem lista aninhada na
      lista principal do inventario.
- [x] View models derivados por aba e arquivos menores em
      `features/character_detail/application/`.
- [x] Abas de inventario, habilidades, magias e notas reorganizadas com
      providers/slivers/keep-alive para reduzir rebuilds pesados.
- [x] Widgets e sheets grandes do detalhe separados em arquivos menores.
- [x] Migracao v5 para ordem explicita de inventario.
- [x] Testes unitarios para inventario, migracoes, feature choices, feature
      usages, criacao de personagem, busca de inventario e backup/importacao.

---

## Serie 2.0.x - Multiclasse

Objetivo: permitir personagens com multiplas classes sem quebrar personagens
existentes. Qualquer mudanca persistida deve usar migracao versionada e o fluxo
de manutencao em Configuracoes.

### 2.0.0 - Modelo e migracao
- [ ] Adicionar estrutura de classes do personagem, como
      `List<CharacterClassEntry>`.
- [ ] Migrar personagem antigo de classe unica para a nova estrutura.
- [ ] Representar hit dice por classe.
- [ ] Separar features por classe/subclasse e nivel de classe.
- [ ] Manter compatibilidade de leitura para personagens antigos ate a migracao.

### 2.0.1 - Spellcasting multiclass
- [ ] Calcular slots combinados do PHB para full, half e third casters.
- [ ] Manter Pact Magic separado para Warlock.
- [ ] Preparacao/conhecimento de magias por classe.
- [ ] Exibir origem da magia quando houver mais de uma classe conjuradora.

### 2.0.2 - Level up multiclass
- [ ] Escolher qual classe sobe de nivel.
- [ ] Adicionar uma nova classe com validacao de pre-requisitos.
- [ ] Aplicar ASI, subclass, features, spells e choices pelo nivel daquela
      classe.
- [ ] Atualizar HP, hit dice, proficiency e recursos derivados corretamente.

### 2.0.3 - UI de ficha multiclass
- [ ] Header com resumo como `Wizard 3 / Cleric 2`.
- [ ] Abas de Habilidades e Magias agrupando origem por classe/subclasse.
- [ ] Edicao posterior de classes com protecoes contra quebrar regras salvas.

---

## Serie 2.1.x - Notas de campanha e sessao

Objetivo: evoluir a area de notas sem perder a simplicidade atual.

### 2.1.0 - Sessoes
- [ ] Agrupar notas por sessao com titulo e data.
- [ ] Criar notas soltas ou vinculadas a uma sessao.
- [ ] Lista de sessoes com preview das notas mais recentes.

### 2.1.1 - Links internos
- [ ] Referenciar personagens, NPCs, locais e itens dentro de notas.
- [ ] Busca global em notas, tags e sessoes.
- [ ] Templates simples para NPC, lugar, missao e loot.

---

## Serie 2.2.x - Mecanicas auxiliares

Objetivo: adicionar ferramentas opcionais de mesa sem sobrecarregar a ficha.

### 2.2.0 - Rolagens
- [ ] Toggle para habilitar/desabilitar dados virtuais.
- [ ] Rolar atributo, pericia, saving throw e ataque a partir da ficha.
- [ ] Historico curto das ultimas rolagens.

### 2.2.1 - Acessibilidade
- [ ] Tamanho de fonte configuravel.
- [ ] Melhorias de contraste e alvos de toque.
- [ ] Revisao de navegacao por teclado/web.

### 2.2.2 - Companheiros e montarias
- [ ] Subficha vinculada ao personagem.
- [ ] Casos principais: familiar, companion, montaria e summons recorrentes.

---

## Serie 2.3.x - Homebrew

Objetivo: permitir conteudo criado/importado pelo usuario sem sobrescrever o
SRD oficial.

### 2.3.0 - Pacotes homebrew
- [ ] Definir formato JSON para classes, racas, backgrounds, magias, itens,
      features, feats e subclasses.
- [ ] Importar pacote homebrew por arquivo.
- [ ] Storage separado para pacotes instalados.
- [ ] Gerenciar pacotes: listar, ver fonte, desativar/remover.

### 2.3.1 - Integracao com criacao e ficha
- [ ] Usar homebrew nas listas de criacao de personagem.
- [ ] Usar magias, itens e features homebrew na ficha.
- [ ] Marcar visualmente conteudo homebrew e sua origem.

---

## Serie 3.0.x - Ferramentas de mestre

Objetivo: expandir o app para uso de mestre sem misturar tudo na ficha do
jogador.

### 3.0.0 - Area de NPCs
- [ ] Navegacao principal com Personagens e NPCs.
- [ ] Modelo de NPC reutilizando partes de Character quando fizer sentido.
- [ ] NPCs fixados, pesquisaveis e organizados por campanha/sessao.

### 3.1.0 - Gerador de NPCs
- [ ] Geracao rapida de NPC com nome, atributos basicos, AC e HP.
- [ ] Geracao com filtros de raca, classe, nivel e importancia.
- [ ] Modo figurante, secundario e importante.

### 3.2.0 - Campanhas
- [ ] Agrupar personagens, NPCs e notas por campanha.
- [ ] Tela de campanha com resumo de party, sessoes, NPCs e pendencias.

---

## Serie 4.0.x - Nuvem e compartilhamento

Objetivo: sincronizacao e colaboracao, mantendo uso local/offline como base.

### 4.0.0 - Conta e sync
- [ ] Backend para conta de usuario.
- [ ] Sincronizacao em nuvem de personagens, notas e imagens.
- [ ] Resolucao de conflitos entre dispositivos.

### 4.1.0 - Compartilhamento
- [ ] Compartilhar personagem por link.
- [ ] Permissoes de leitura/copia.
- [ ] Export/import continuando funcional sem conta.

### 4.2.0 - Imagens geradas
- [ ] Gerar imagem do personagem a partir de raca, classe e aparencia.
- [ ] Permitir editar prompt antes de gerar.
- [ ] Salvar imagem gerada como avatar local/sincronizado.

---

## Ideias futuras

- Companheiro de IA para narrar, resumir sessoes ou sugerir acoes.
- Bestiario com monstros prontos.
- Modo campanha compartilhada em tempo real.
- Suporte a outros sistemas de RPG alem de D&D 5e.
