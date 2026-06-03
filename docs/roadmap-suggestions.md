# Roadmap — Sugestões de funcionalidades

Gaps identificados comparando o estado atual do app com o que é necessário numa sessão real de D&D 5e.

---

## Alta prioridade — afeta diretamente o uso na mesa

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

## Média prioridade — qualidade de vida

### Peso do Inventário
Sem cálculo de carga carregada vs. capacidade (Strength × 15 lb).

**O que implementar:**
- Adicionar campo `weight` opcional nos itens de equipamento do SRD
- Barra de progresso de carga na aba de Inventário
- Limites: encumbered (×5 STR), heavily encumbered (×10 STR), máximo (×15 STR)

### Unidades por região
Em inglês a medida de distância é feet (ft) e peso é lb; em outros idiomas são usados metros (m) e kg. Jogadores com grid preferem pensar em squares.

**Design decidido:**
- Configuração explícita de sistema de unidades nas preferências do app: **Imperial (ft / lb)**, **Métrico (m / kg)** ou **Squares (sq)**
- O padrão é determinado pelo locale do dispositivo: `en` → Imperial; demais → Métrico
- O usuário pode sobrescrever manualmente a qualquer momento
- Squares: distâncias exibidas em quadrados (1 sq = 5 ft = 1,5 m); peso permanece em lb ou kg conforme locale

**O que implementar:**
- Campo `unitSystem` (enum: `imperial` / `metric` / `squares`) em SharedPreferences
- Inicializar com base em `Localizations.localeOf(context).languageCode == 'en'`
- Helper `formatDistance(int feet)` → "30 ft" / "9 m" / "6 sq"
- Helper `formatWeight(double lb)` → "15 lb" ou "6,8 kg" (squares usa kg como peso)
- Aplicar os helpers onde velocidade (Speed) e pesos de inventário são exibidos
- Toggle de 3 opções nas configurações (tela de Settings ou dialog de preferências)

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

1. **Descanso Curto/Longo** — alto impacto em sessão, requer lógica de recuperação de slots/HD
2. **Concentração** — pequena adição ao modelo + UI de magia
3. **Peso do inventário** — depende de adicionar `weight` ao SRD JSON
4. **Unidades por região** — melhoria de UX para jogadores fora dos EUA
5. **Dado Virtual** — nice-to-have para quem joga sem dados físicos
6. **Notas por Sessão** — organização avançada para campanhas longas
