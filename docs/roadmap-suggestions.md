# Roadmap — Sugestões de funcionalidades

Gaps identificados comparando o estado atual do app com o que é necessário numa sessão real de D&D 5e.

---

## Média prioridade — qualidade de vida

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

## Média prioridade — qualidade de vida (Settings)

### Tamanho de Fonte
Acessibilidade — telas pequenas ou jogadores com dificuldade de leitura.

**O que implementar:**
- Opção nas configurações: **Pequeno / Normal / Grande** (3 tamanhos)
- Salvo em SharedPreferences, aplica um `TextScaleFactor` customizado via `MediaQuery` no root do app

### Toggle de Dado Virtual
Quem joga com dados físicos não quer o botão de rolagem ocupando espaço na ficha.

**O que implementar:**
- Toggle nas configurações globais para habilitar/desabilitar os botões de rolagem de dados na ficha
- Desabilitado por padrão (respeita quem prefere dados físicos)

---

## Baixa prioridade / nice-to-have

### Dado Virtual
Rolagem de dados integrada para quem joga solo ou digital (sem física de dado).

- Rolar 1d20 + modificador diretamente de um atributo/perícia com tap longo
- Histórico da última rolagem visível
- Depende do toggle de Dado Virtual estar habilitado nas configurações

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
