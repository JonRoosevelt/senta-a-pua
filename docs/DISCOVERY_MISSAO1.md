# 🎯 Descoberta: Missão 1 — Batismo de Fogo (Ponte de Piave)

## Contexto Histórico Real
- **Data:** Novembro de 1944
- **Local:** Rio Piave, norte da Itália (Vêneto)
- **Situação:** Primeiras missões de combate do 1º GAvCa recém-chegado à Itália
- **Foco real:** Interdição de pontes ferroviárias para cortar suprimentos alemães à Linha Gótica
- **Condições:** Outono italiano — neblina matinal, folhagem alaranjada, montanhas ao fundo

## 🎨 Direção Visual: Outono Italiano no Vale do Pó
### Referências pesquisadas:
- **Cores do outono:** tons de laranja, âmbar, marrom-avermelhado nas árvores
- **Neblina matinal:** fog denso sobre o rio, dissipando com o sol
- **Rio Piave:** rio largo e pedregoso (não azul profundo, mas cinza-esverdeado)
- **Ponte ferroviária:** estrutura de metal/ferro, vários pilares, trilhos no topo
- **Céu:** azul pálido de outono, nuvens cirrus finas
- **Montanhas:** Dolomitas ao fundo, picos já com neve
- **Vegetação:** choupos italianos (não só ciprestes), vinhedos em terraços

### Paleta de Cores para esta missão:
```
Céu:          #7BA4C4 (azul pálido outonal)
Horizonte:    #D4A574 (laranja suave)
Montanhas:    #8B7D9B (roxo-acizentado) / neve #E8E4EF
Rio:          #6B8E7B (verde-acizentado)
Campos:       #C4A44A (dourado outonal) / #8B6914 (terra)
Árvores:      #CC5500 (laranja queimado) / #8B4513 (marrom)
Ponte:        #4A4A4A (ferro escuro)
Neblina:      fog com densidade 0.015, cor creme
```

## ⚙️ Requisitos Técnicos para a Missão

### A. Sistema de Objetivos (GameManager)
- [ ] Objetivos com progresso individual (não só contagem total)
- [ ] Vitória = TODOS os objetivos concluídos
- [ ] Cada tipo de alvo reporta separadamente
- [ ] HUD mostra progresso dos objetivos

### B. Destruíveis
- [x] Torres Flak (já existem)
- [x] Caças inimigos (já existem)
- [ ] **Ponte ferroviária** - NOVO: StaticBody3D com HP, múltiplos segmentos
- [ ] **Pilares da ponte** - NOVO: cada pilar é um alvo separado (3 pilares = 3 hits)

### C. Cenário Específico
- [ ] Terreno outonal (grama dourada, não verde)
- [ ] Rio Piave largo e pedregoso
- [ ] Neblina matinal (WorldEnvironment fog)
- [ ] Árvores outonais (choupos, não ciprestes)
- [ ] Ponte ferroviária no centro do mapa
- [ ] Montanhas Dolomitas ao fundo (mais largas, menos pontiagudas)

### D. Checkpoints
- [ ] Sistema de salvamento automático após cada objetivo concluído
- [ ] Morrer = reinicia do último checkpoint (não perde piloto)
- [ ] Perder piloto só se morrer 3 vezes no mesmo checkpoint

### E. HUD de Objetivos
- [ ] Lista de objetivos no canto superior direito
- [ ] Checkmarks conforme completa
- [ ] Indicador de progresso (2/3 pontes, etc.)

## 📋 Ordem de Implementação (iterativa)
1. ✅ Discovery & documentação
2. 🔄 Sistema de objetivos no GameManager
3. 🔄 Ponte destruível (scene_builder + script)
4. 🔄 Cenário outonal (variação do scene_builder)
5. 🔄 Checkpoints
6. 🔄 HUD de objetivos
7. 🔄 Teste & ajuste
