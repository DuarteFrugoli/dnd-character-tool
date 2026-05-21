# XP Tracking — Como Funciona

## Campo no modelo

`Character.xpTrackingEnabled` (`bool`, padrão `false`) — persistido no JSON.

---

## Tracking DESATIVADO (padrão)

O painel de Progressão aparece **opaco (40%)** e não é interativo (`AbsorbPointer`).

| Elemento | Comportamento |
|---|---|
| Botão Level Up (AppBar) | **Visível** — o usuário pode subir de nível manualmente |
| Botão `+` de nível (aba Identidade) | **Visível** — incremento manual de nível |
| Painel de XP / barra de progresso | Visível mas **não interativo** |
| Campo XP no modo edição | Visível mas **não interativo** (AbsorbPointer ainda ativo) |
| XP ao trocar de nível manualmente | **Preservado** — não é alterado |
| XP após completar o Level Up Wizard | **Preservado** — não é alterado |

O XP existe no personagem mas é meramente informativo. O usuário controla o nível manualmente.

---

## Tracking ATIVADO

O painel de Progressão fica **totalmente interativo**.

| Elemento | Comportamento |
|---|---|
| Botão Level Up (AppBar) | **Oculto** |
| Botão `+` de nível (aba Identidade) | **Oculto** |
| Painel de XP / barra de progresso | **Interativo** |
| XP ao trocar de nível manualmente (`updateLevel`) | Ajustado para o **mínimo do novo nível** |
| XP após completar o Level Up Wizard (`levelUp`) | Ajustado para o **mínimo do novo nível** |

### Ao ativar o toggle

`updateXpTracking(true)` verifica se o XP atual está **abaixo do mínimo** para o nível atual:

```
minXp = levelToMinXp(character.level)
if (xp < minXp) → xp = minXp
```

Garante que o rastreamento sempre comece num estado válido.

### Ao desativar o toggle

`updateXpTracking(false)` apenas salva a flag. O XP **não é alterado**.

---

## Painel de XP (tracking ativo)

```
Nível N                              1250 XP
████████████░░░░░░░░░░░░░░░░  (barra de progresso)
1750 XP → Nível N+1

[ − ] [ 500 ] [ + ]   [ Adicionar XP ]

▾ Tabela de Níveis
```

- O **nível exibido** vem de `character.level` (fonte da verdade), não de `xpToLevel(xp)`.
- A barra de progresso é clampada em `[0.0, 1.0]` para evitar valores negativos.
- A **tabela de níveis** expande mostrando o XP mínimo de cada nível (1–20), com o nível atual destacado.

---

## Fluxo de Adicionar XP

Chamada: `_addXp(amount)` em `_StatsTabState`.

### Proteção contra double-tap

Um bool `_xpAddInProgress` bloqueia chamadas concorrentes. Se o usuário toca o botão enquanto uma chamada já está em andamento, a segunda é ignorada. O flag é liberado no `finally`.

### Lógica principal

```
newXp = (xp + amount).clamp(0, 999_999)

se level < 20 E newXp >= kXpThresholds[level] E xp < kXpThresholds[level]:
  → salva newXp imediatamente (XP completo ganho)
  → exibe diálogo "Subir de Nível?"
    ├─ "Agora"   → abre Level Up Wizard
    │              (wizard chama levelUp() → XP = mínimo do novo nível)
    └─ "Depois" / dismiss → capa XP em kXpThresholds[level]
                             (estado pendente fica visível)
senão:
  → salva newXp normalmente
```

> **Nota sobre o cap:** ao dizer "Depois", o XP fica travado **exatamente** no valor do threshold do próximo nível (ex: 300 para o nível 2). Qualquer XP acima desse valor já foi salvo antes do diálogo, mas é descartado ao confirmar "Depois".

---

## Estado Pendente de Level Up

Detectado por `_isPendingLevelUp(c)`:

```dart
c.xpTrackingEnabled && c.level < 20 && c.experiencePoints >= kXpThresholds[c.level]
```

Quando pendente:

- A linha de "Adicionar XP" some.
- Aparece um `FilledButton` — **"Pronto para subir de nível!"**
- Ao tocar, o Level Up Wizard é aberto.
- Após o wizard, `levelUp()` define `xp = levelToMinXp(novoNível)`, o estado pendente desaparece.

---

## Thresholds de XP (D&D 5e SRD)

Definidos em `lib/data/constants/level_up_rules.dart` como `kXpThresholds`:

| Nível | XP mínimo |
|---|---|
| 1 | 0 |
| 2 | 300 |
| 3 | 900 |
| 4 | 2.700 |
| 5 | 6.500 |
| 6 | 14.000 |
| 7 | 23.000 |
| 8 | 34.000 |
| 9 | 48.000 |
| 10 | 64.000 |
| 11 | 85.000 |
| 12 | 100.000 |
| 13 | 120.000 |
| 14 | 140.000 |
| 15 | 165.000 |
| 16 | 195.000 |
| 17 | 225.000 |
| 18 | 265.000 |
| 19 | 305.000 |
| 20 | 355.000 |

Funções auxiliares:
- `xpToLevel(int xp) → int` — retorna o nível correspondente ao XP
- `levelToMinXp(int level) → int` — retorna o XP mínimo para aquele nível

---

## Arquivos Relevantes

| Arquivo | Responsabilidade |
|---|---|
| `lib/data/constants/level_up_rules.dart` | `kXpThresholds`, `xpToLevel`, `levelToMinXp` |
| `lib/data/models/character.dart` | Campo `xpTrackingEnabled` |
| `lib/data/models/character.g.dart` | Serialização JSON (leitura com `?? false`) |
| `lib/features/character_detail/character_detail_provider.dart` | `updateXpTracking`, `updateLevel`, `levelUp` |
| `lib/features/character_detail/tabs/stats_tab.dart` | UI do painel, `_addXp`, `_isPendingLevelUp` |
| `lib/features/character_detail/character_detail_screen.dart` | Botão Level Up da AppBar (oculto quando ativo) |
| `lib/features/character_detail/tabs/identity_tab.dart` | Botão `+` de nível (oculto quando ativo) |
