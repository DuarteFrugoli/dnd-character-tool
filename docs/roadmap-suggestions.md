# Roadmap — Sugestões de funcionalidades

Gaps identificados comparando o estado atual do app com o que é necessário numa sessão real de D&D 5e.

---

## Alta prioridade — afeta diretamente o uso na mesa

### Death Saves (Salvaguardas de Morte) (implementado)
Quando o personagem chega a 0 HP precisa rolar 1d20 por turno: 10+ = sucesso, 9- = falha.
3 sucessos = estabilizado, 3 falhas = morto. Sem rastrear isso no app, o jogador precisa de papel.

**O que implementar:**
- 3 checkboxes de sucesso + 3 checkboxes de falha na aba de Stats
- Exibidos apenas quando HP atual = 0 (ou condicional visível)
- Persistidos no modelo `Character`
- Zerados automaticamente ao receber cura (HP > 0)

---

### Condições Ativas
Condições como Blinded, Charmed, Frightened, Poisoned têm efeito mecânico direto (desvantagem, imunidades, velocidade 0, etc.) e aparecem em todo combate.

**O que implementar:**
- Lista das 15 condições do SRD (Blinded, Charmed, Deafened, Exhaustion, Frightened, Grappled, Incapacitated, Invisible, Paralyzed, Petrified, Poisoned, Prone, Restrained, Stunned, Unconscious)
- Chips clicáveis na aba de Stats para ativar/desativar
- Condição ativa exibe descrição resumida (bottom sheet)
- Persistidas no modelo `Character` como `List<String>`

---

### Salvaguardas (Saving Throws)
As proficiências já estão no JSON de classes mas não há exibição dos valores calculados (+mod + proficiência) na ficha.

**O que implementar:**
- Seção "Saving Throws" na aba de Skills (ou Stats) com os 6 valores calculados
- Ícone de proficiência ao lado dos proficientes da classe

---

## Média prioridade — qualidade de vida

### Descanso Curto e Longo
Sem mecanismo para aplicar os efeitos de descanso: recuperar HD, slots de magia, usos de features.

**O que implementar:**
- Botões "Descanso Curto" e "Descanso Longo" (menu ou FAB na aba de Stats)
- Descanso curto: permite gastar HD para recuperar HP
- Descanso longo: recupera todos os slots, metade dos HD, HP máximo
- Dialog de confirmação listando o que será recuperado

---

### Concentração
Sem indicador de qual magia está em concentração ativa. Comum esquecer e empilhar duas magias.

**O que implementar:**
- Campo `concentrationSpell: String?` no modelo
- Badge ou chip na aba de Magias indicando a magia em concentração
- Ao preparar uma segunda magia de concentração: aviso de que a anterior será interrompida

---

### Peso do Inventário
Sem cálculo de carga carregada vs. capacidade (Strength × 15 lb).

**O que implementar:**
- Adicionar campo `weight` opcional nos itens de equipamento do SRD
- Barra de progresso de carga na aba de Inventário
- Limites: encumbered (×5 STR), heavily encumbered (×10 STR), máximo (×15 STR)

### Unidades por região
Em inglês a medida de distância é feet (ft) e peso é lb; em outros idiomas são usados metros (m) e kg.

**Design decidido:**
- Configuração explícita de sistema de unidades nas preferências do app: **Imperial (ft / lb)** ou **Métrico (m / kg)**
- O padrão é determinado pelo locale do dispositivo: `en` → Imperial; demais → Métrico
- O usuário pode sobrescrever manualmente a qualquer momento

**O que implementar:**
- Campo `unitSystem` (enum: `imperial` / `metric`) em SharedPreferences
- Inicializar com base em `Localizations.localeOf(context).languageCode == 'en'`
- Helper `formatDistance(int feet)` → "30 ft" ou "9 m" (5 ft = 1,5 m, conforme edições oficiais)
- Helper `formatWeight(double lb)` → "15 lb" ou "6,8 kg" (1 lb ≈ 0,45 kg)
- Aplicar os helpers onde velocidade (Speed) e pesos de inventário são exibidos
- Toggle nas configurações (tela de Settings ou dialog de preferências)

---

## Baixa prioridade / nice-to-have

### Dado Virtual
Rolagem de dados integrada para quem joga solo ou digital (sem física de dado).

- Rolar 1d20 + modificador diretamente de um atributo/perícia com tap longo
- Histórico da última rolagem visível

---

### Notas por Sessão
A aba de Notas é um campo livre único. Dificulta organizar anotações de sessões diferentes.

- Notas organizadas com título de sessão e data
- Lista de notas com preview

---

### Companheiros e Montarias
Fora do escopo imediato, mas relevante para classes como Ranger e Paladin.

---

## Ordem de implementação sugerida

1. **Death Saves** — simples de implementar, enorme impacto prático
2. **Condições Ativas** — dados já disponíveis no SRD, só precisa de UI
3. **Salvaguardas calculadas** — dados já existem no modelo, só falta exibição
4. **Descanso curto/longo** — requer lógica de recuperação de slots/HD
5. **Concentração** — pequena adição ao modelo + UI de magia
6. **Peso do inventário** — depende de adicionar `weight` ao SRD JSON
