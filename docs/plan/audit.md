Bugs (P0 — corrigir primeiro)
#1 — Memory leak: TextEditingController não disposto (character_detail_screen.dart ~L687)
_showTempHpDialog() cria um controller local e nunca chama .dispose(). Todos os controllers precisam ser dispostos.

#2 e #3 — Race condition de tema e locale (theme_provider.dart, locale_provider.dart)
_loadFromPrefs() e _load() são chamados sem await no build(). O app pisca com o tema/idioma padrão antes de carregar o salvo. Precisa de AsyncNotifierProvider ou carregar antes do runApp().

#4 — Race condition no reorder (character_list_provider.dart)
Estado é atualizado na UI antes dos saves terminarem. Se o usuário reordenar rápido duas vezes, o primeiro reorder é perdido.

#19 — Mounted check faltando após dialog (character_detail_screen.dart ~L625)
_showBackgroundDialog() chama _notifier.updateBackground() após await showDialog() sem checar mounted. Pode crashar se o usuário navegar para fora.

Performance (P1-P2)
#5 — Refresh flood após mutações — cada delete/rename/updateImage chama refresh() forçando reload completo. Melhor atualizar estado in-place.

#6 e #9 — SpellBrowserSheet — filtros recalculam a lista inteira no cada rebuild; .toLowerCase() em 300+ magias a cada frame. Pré-calcular nomes em lowercase no load.

#8 — SRD carregado sem cache — getRaces() lê o asset bundle a cada chamada em syncInnateSpells().

Qualidade de código (P2-P3)
#10 — character_detail_screen.dart com +5400 linhas — 6 abas num único arquivo. Prioridade alta de manutenibilidade.

#11 e #12 — Código duplicado — _skillAbility map e funções _mod()/_sign() existem em múltiplos arquivos. Deveriam estar em utils.

#18 — Bug de string interpolation (character_draft_provider.dart ~L570) — '\$g:\$i' pode estar sendo salvo como literal $g:$i em vez de 0:1. Vale checar.