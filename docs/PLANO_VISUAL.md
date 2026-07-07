# 🎨 Plano de Refinamento Visual - Senta a Pua!

## Status: Em andamento — Passo 1 e 2

---

## 📸 Referências Visuais Aprovadas
(Ver screenshots enviados em 07/07/2026)

1. **Vila rural militar** — vilarejos italianos com veículos militares, terreno arenoso, composição agrupada
2. **FPS cidade com tanques** — prédios telhados laranja, paleta marrom/laranja/cinza, escala de construções
3. **⭐ Isométrico campo de batalha** (REFERÊNCIA PRINCIPAL) — terreno com grama verde, elevações, rochas, vegetação, veículos militares
4. **Vila italiana vintage** — arquitetura italiana, prédios bege/marrom/avermelhado, colinas ao fundo
5. **Rio e montanhas com floresta** — água azul natural, montanhas cobertas de árvores
6. **Vista aérea montanhosa** — integração terreno-montanha, rio azul claro, vegetação densa

---

## 🎯 Direção Visual Alvo
**Estilizado realista + low-poly polido** — silhuetas reconhecíveis, texturas sutis, iluminação atmosférica, sem aparência infantil.

---

## ✅ Passo 1: Cores Históricas dos Inimigos
*Corrigir inimigos vermelhos (irrealistas) para pinturas históricas da WWII.*

- [ ] **Caça inimigo → Messerschmitt Bf-109 G-6**
  - Fuselagem: cinza-esverdeado RAL 7009 (#4A4E4D)
  - Barriga: azul-claro RLM 76 (#8C9DA7)
  - Asas: cinza-escuro camuflagem (#3D4040)
  - Hélice/spinner: preto com espiral branco
- [ ] **Torre Flak → Flak 36 88mm alemã**
  - Base: concreto cinza (#6B6B6B)
  - Cano: aço escuro (#2A2A2E)
  - Escudo: cinza-escuro blindado (#3A3C3E)
  - Pequenos detalhes: rodas ou base giratória

---

## ✅ Passo 2: Terreno com Textura Procedural
*Substituir chão marrom liso por terreno com variação de cor usando NoiseTexture2D.*

- [ ] Criar textura de grama/terra com FastNoiseLite + NoiseTexture2D
  - Tons: verde-musgo, marrom-terra, bege-arenoso
  - Escala: 0.02 (detalhes finos) + 0.005 (macro variação)
  - Noise type: Simplex
- [ ] Aplicar como albedo_texture no material StandardMaterial3D do chão
- [ ] Adicionar variação sutil de altura (opcional, pode ser só cor)
- [ ] Testar: chão deve mostrar variação de verde/marrom, não cor sólida

---

## 🔜 Passo 3: Montanhas Integradas ao Terreno
*Fim das montanhas flutuando. Conexão visual entre chão e montanha.*

- [ ] Base com textura de terra/grama (Y=0 a 20% altura)
- [ ] Meio rochoso cinza-azulado (20% a 80% altura)
- [ ] Topo nevado (>80% altura)
- [ ] Conectar geometria ao terreno (sem gap entre chão e montanha)

---

## 🔜 Passo 4: Organização Espacial dos Assets
*Assets agrupados em composições intencionais, não espalhados aleatoriamente.*

- [ ] Vilarejos agrupados (8-12 prédios em raio de 30m)
- [ ] Bosques (15-20 árvores em raio de 20m)
- [ ] Rochas concentradas nos sopés das montanhas
- [ ] Estradas conectando vilarejos (linhas de terra batida)
- [ ] Rio com margens de pedra/areia (não só água sobre grama)

---

## 🔜 Passo 5: Avião P-47 Thunderbolt (Modelo 3D Real)
*Gerar ou modelar P-47 com silhueta reconhecível. Não mais caixas.*

- [ ] Fuselagem: barril arredondado (cilindro facetado)
- [ ] Asas: formato elíptico com borda de ataque curva
- [ ] Cockpit: canopy bolha (P-47D Bubbletop)
- [ ] Motor radial: cilindros visíveis no cowl
- [ ] Pintura: verde-oliva FAB com insígnia amarela no cowl
- [ ] Insígnias: estrela FAB nas asas e fuselagem

---

## 🔜 Passo 6: Inimigo Bf-109 (Modelo 3D Real)
*Caça alemão histórico para substituir o "avião vermelho" atual.*

- [ ] Fuselagem: esguia e estreita (diferente do P-47 robusto)
- [ ] Asas: trapezoidais com pontas arredondadas
- [ ] Cockpit: canopy quadrado (não bolha)
- [ ] Pintura: cinza camuflagem com barriga azul-claro

---

## 📋 Aprendizados das Referências

| O que estava ERRADO | O que as referências mostram |
|---|---|
| Chão marrom liso 1 cor | Grama verde com variação marrom/bege |
| Montanhas flutuando no horizonte | Montanhas integradas ao terreno |
| Objetos espalhados aleatoriamente | Composição agrupada (vilas, bosques) |
| Inimigos vermelhos | Pintura militar histórica (cinza/verde) |
| Água turquesa saturada | Água azul-esverdeada natural |
| Sem texturas (cores sólidas) | Texturas sutis com variação |

---

> **Progresso:** Iniciando Passo 1 (cores históricas inimigos) e Passo 2 (terreno procedural).
>
> **Commits de referência:** `2d4479a` (Piave v2), `da9357d` (fix fog)
