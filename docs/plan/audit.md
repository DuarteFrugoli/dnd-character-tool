Bugs (P0 — corrigir primeiro)

#2 e #3 — Race condition de tema e locale (theme_provider.dart, locale_provider.dart)
_loadFromPrefs() e _load() são chamados sem await no build(). O app pisca com o tema/idioma padrão antes de carregar o salvo. Precisa de AsyncNotifierProvider ou carregar antes do runApp().

Performance (P1-P2)
#5 — Refresh flood após mutações — cada delete/rename/updateImage chama refresh() forçando reload completo. Melhor atualizar estado in-place.

Qualidade de código (P2-P3)

#11 e #12 — Código duplicado — _skillAbility map e funções _mod()/_sign() existem em múltiplos arquivos. Deveriam estar em utils.