# 🎨 Plano de Assets Low-Poly - Senta a Pua!

## Contexto: Vale do Pó, Itália (1944-1945)

O teatro de operações do 1º GAvCa foi o norte da Itália, especificamente o Vale do Pó. 
A estética alvo é **low-poly de alto contraste**: geometria facetada, cores sólidas, iluminação dramática.

---

## Assets por Categoria

### 🏔️ Terreno & Ambiente
| Asset | Estado Atual | Alvo |
|---|---|---|
| Ground | ✅ Grid de placas facetadas verdes com shading per-pixel | ~~Caixa roxa plana~~ |
| Mountains | ✅ Alpes em camadas geométricas (8 layers, topo nevado) | ~~2 caixas roxas~~ |
| River/Po River | ✅ Rio azul geométrico cortando o vale | ~~Não existia~~ |
| Fields/Farmland | ✅ Placas geométricas verdes/marrons (terreno) | ~~Não existia~~ |
| Roads | ❌ Não existe | Faixas cinza conectando pontos no mapa |
| Trees | ✅ Ciprestes italianos (tronco + 5 camadas de folhagem) | ~~Não existia~~ |
| Village/Buildings | ✅ Vilarejo com telhados terracota + igreja com torre | ~~Não existia~~ |

### 🏗️ Estruturas Militares (Alvos)
| Asset | Estado Atual | Alvo |
|---|---|---|
| Flak Tower | ✅ Base de concreto + cano angulado + escudo blindado | ~~Caixa vermelha~~ |
| Train/Bridge | ✅ Ponte com pilares + locomotiva + 3 vagões | ~~Não existia~~ |
| Supply Convoy | ❌ Não existe | Caminhões militares low-poly em comboio |
| Artillery Nest | ❌ Não existe | Ninhos de artilharia com sacos de areia geométricos |
| Ammo Dump | ✅ Caixas empilhadas (alvo destrutível) | ~~Não existia~~ |
| Bunker | ❌ Não existe | Bunker de concreto facetado |

### ✈️ Aeronaves
| Asset | Estado Atual | Alvo |
|---|---|---|
| P-47 Thunderbolt (Player) | Caixas montadas | Modelo low-poly mais refinado (cilindros facetados, asas curvadas) |
| Enemy Fighter (Folgore/Bf-109) | Caixas montadas vermelhas | Caça italiano Macchi C.202 Folgore ou Bf-109 low-poly |
| Bomber (aliado) | Não existe | B-25 Mitchell para missões de escolta |

### 💥 Efeitos
| Asset | Estado Atual | Alvo |
|---|---|---|
| Explosions | ✅ Sistema dual: fogo emissivo + fumaça escura | ~~Cubos laranja só~~ |
| Tracers | ✅ Ok (glow laranja/vermelho) | Manter |
| Smoke columns | ✅ Coluna de fumaça persistente pós-destruição | ~~Não existia~~ |
| Fire | ❌ Não existe | Chamas low-poly no chão após bombardeio |
| Muzzle flash | ❌ Não existe | Flash na boca das metralhadoras ao disparar |

### 🖼️ UI 2D
| Asset | Estado Atual | Alvo |
|---|---|---|
| Crosshair | ✅ Ok | Manter |
| HUD Panel | ✅ Ok | Adicionar estilo militar 1940s (bordas, fonte) |
| Briefing screen | Não existe | Tela com mapa tático e objetivos da missão |
| Minimap/Radar | Não existe | Indicador de direção de inimigos |

---

## Prioridade de Implementação

1. ✅ ~~**Terreno do Vale do Pó**~~ - concluído
2. ✅ ~~**Torres Flak refinadas**~~ - concluído
3. ✅ ~~**Ponte + Trem**~~ - concluído
4. ✅ ~~**Vilarejo Italiano**~~ - concluído
5. ✅ ~~**Árvores (ciprestes)**~~ - concluído
6. 🔄 **Modelos de aviões refinados** - P-47 melhorado, inimigo Folgore
7. ❌ **Prédios/bunkers** - variedade de alvos
8. ✅ ~~**Fumaça e fogo**~~ - parcial (explosões + fumaça, falta fogo no chão)
9. 🔄 **Correção shading** - ✅ concluído (per-pixel substituiu unshaded)
