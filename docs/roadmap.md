# Roadmap

Este documento resume a direcao do app por versao. Ele nao substitui o
`CHANGELOG.md`: aqui entram apenas os blocos grandes de produto e arquitetura.

## Modelo de produto

| Nivel | Conta | O que inclui |
| --- | --- | --- |
| Sem conta | Nao | App completo e offline: todo o conteudo, criacao, ficha, level up, export/import e backups locais. |
| Sync | Sim, paga | Personagens e fotos na nuvem, varios aparelhos e acesso pela web. |
| Mestre | Sim, paga | Tudo do Sync mais a area do mestre. |

Principios:

- A ficha de jogador continua generosa: personagens ilimitados, uso offline,
  importacao/exportacao e recursos essenciais sem travas artificiais.
- Nao existe plano gratuito com conta. Quem nao assina usa o app sem conta;
  a conta existe para quem assina.
- Conteudo nunca e vendido. Todo conteudo de regras fica liberado para todos.
  O que se cobra sao recursos com custo recorrente (nuvem) e ferramentas de
  mestre.
- O aparelho e a fonte da verdade. A nuvem e uma copia controlada pelo
  usuario: o app envia as mudancas, e baixar da nuvem e sempre uma escolha do
  usuario, mesmo que a versao da nuvem esteja atras.
- A area do mestre e totalmente paga e inclui o Sync.
- Planos mensal e anual com desconto. Compra vitalicia fica fora do
  lancamento; pode ser reavaliada depois.
- Compras feitas por Play Billing, StoreKit ou checkout web viram direitos de
  uso na conta do usuario, para evitar logica duplicada por plataforma.
- Conteudo fora do SRD segue como resumos originais. Se algum conteudo
  precisar sair do app oficial, ele pode migrar para homebrew criado e
  compartilhado pela comunidade.
- Conteudo publico de comunidade e IA exigem backend, politicas, denuncia e
  moderacao antes de serem lancados.

---

## Trilha continua - Conteudo 2014 e 2024

Objetivo: completar as opcoes de jogador e, depois, o material de mestre das
duas edicoes, em entregas pequenas junto com as features. Inclui livros alem
do Player's Handbook.

- [ ] 2024: completar o Player's Handbook 2024 (lista priorizada em
      `docs/CONTENT_COVERAGE.md`, secao D&D 2024).
- [ ] 2024: traduzir as 36 subclasses fora do SRD e os novos conteudos nos
      11 idiomas.
- [ ] 2024: tirar o rotulo Beta quando o PHB 2024 estiver completo.
- [ ] Bestiario completo do SRD 5.1 e 5.2.1 como base da area do mestre.
- [ ] Livros posteriores das duas edicoes (opcoes de jogador e material de
      mestre), sempre como resumos originais fora do SRD.

---

## Serie 3.1+x - Conta, Sync e Mestre

### 3.1.0 - Conta e Sync (Android)

Objetivo: lancar a primeira assinatura, de sincronizacao de personagens, sem
mudar nada para quem usa o app sem conta. Especificacao em
`docs/SYNC_SPEC.md`.

- [ ] Backend Supabase: autenticacao, tabelas, RLS e storage de imagens.
- [ ] Login com Google no Android.
- [ ] Assinatura Sync via Play Billing, por RevenueCat, com direitos
      gravados na conta.
- [ ] Envio automatico das mudancas e download sob demanda.
- [ ] Estados por personagem: em dia, nuvem mais nova, divergiu.
- [ ] Divergencia: manter local, usar a da nuvem ou duplicar o personagem com
      as duas versoes.
- [ ] Assinatura vencida: envio pausado, download liberado por 90 dias, depois
      a copia na nuvem e apagada com aviso previo.
- [ ] Excluir conta dentro do app e por pagina web.
- [ ] Atualizar politica de privacidade e Seguranca de Dados da Play Store.

### 3.2.0 - Area do Mestre

Objetivo: abrir a assinatura Mestre, mais cara, que inclui o Sync.

- [ ] Tela "Mestre" separada da ficha de jogador.
- [ ] Criacao de homebrews: itens, magias, features, feats, especies,
      backgrounds, subclasses e classes quando a base estiver pronta.
- [ ] Importar/exportar pacotes de homebrew por arquivo.
- [ ] Gerenciar pacotes instalados: listar, ver fonte, desativar/remover.
- [ ] Usar homebrew nas listas de criacao, ficha, inventario e magias.
- [ ] Marcar visualmente conteudo homebrew e sua origem.
- [ ] Monstros/NPCs salvos e sincronizados.
- [ ] Geradores simples para NPCs, encontros, loot e notas de sessao.
- [ ] Sync de campanhas, notas e homebrews.

### 3.3.0 - iOS

Objetivo: publicar na App Store com as mesmas assinaturas.

- [ ] Validar build, testes XCTest e importacao/compartilhamento no iPhone e
      iPad (`docs/IOS_FILE_TESTING.md`).
- [ ] Sign in with Apple, exigido junto do login com Google.
- [ ] Assinaturas via StoreKit no RevenueCat, reconhecidas pela mesma conta.

### Web (a decidir)

Tendencia: manter a web. Sem conta, ela continua local e gratuita (IndexedDB).
Com conta de assinante, mostra os mesmos personagens do celular. Pendente:
checkout web (Stripe via RevenueCat) e o custo de testes por plataforma.

---

## Serie 4.x - Mesa compartilhada e ferramentas avancadas

Objetivo: expandir a assinatura Mestre para uma experiencia de mesa online sem
perder a base offline do app.

### 4.0.0 - Campanhas compartilhadas
- [ ] Campanhas com jogadores convidados.
- [ ] Jogadores entram e controlam seus proprios personagens.
- [ ] Permissoes por jogador/personagem.
- [ ] Sincronizacao simples de HP, condicoes, recursos e notas compartilhadas.
- [ ] Compartilhar personagem/campanha por link.

### 4.1.0 - Grid 2D simples
- [ ] Grid de batalha 2D leve, com tokens de personagens, NPCs e monstros.
- [ ] Medidas, posicao, iniciativa e estados simples.
- [ ] Funcionar bem em tablet, web e mobile.

### 4.2.0 - Ferramentas de encontro
- [ ] Encontros salvos por campanha.
- [ ] Monstros prontos e homebrew.
- [ ] Iniciativa compartilhada.
- [ ] Loot e recompensas aleatorias.

---

## Ideias futuras

- Biblioteca publica de homebrew da comunidade, com denuncia, ocultacao,
  bloqueio e fila de moderacao.
- IA com creditos para historia, NPCs, encontros, loot, descricoes e imagens
  (planejado antes; precisa ser reavaliado no novo modelo).
- Notas de campanha com sessoes, links internos e templates avancados.
- Acessibilidade: tamanho de fonte, contraste e navegacao por teclado/web.
- Companheiros, montarias, familiares e summons recorrentes.
- Suporte a outros sistemas de RPG alem de D&D 5e.
