# Senta a Pua! — Agentes

Regras e contexto para agentes de IA que trabalham neste projeto.

---

## 📋 Regras Fundamentais

### 1. Plano de Desenvolvimento é a fonte da verdade
- O arquivo [`PLANO_DE_DESENVOLVIMENTO.md`](./PLANO_DE_DESENVOLVIMENTO.md) descreve TODAS as fases — concluídas, em andamento e futuras.
- **Toda decisão de implementação deve consultar o plano primeiro.**
- Se algo não está no plano, pergunte se deve estar ou se é uma adição válida.

### 2. Atualizar o plano a cada commit significativo
- Após qualquer commit que adicione/altere funcionalidade, **atualize o plano**:
  - Marque checkboxes concluídos `[x]`
  - Adicione novas fases se necessário
  - Atualize o progresso na nota de rodapé
  - Atualize commits de referência
- Commits triviais (typos, formatação, debug logs) não precisam de update.
- Se a mudança afeta o diagrama Mermaid, atualize também.

### 3. Sempre seguir a ordem das fases
- Não pule fases a menos que explicitamente autorizado.
- Se uma fase futura depende de algo ainda não feito, priorize a fase atual.
- O diagrama Mermaid mostra as dependências — respeite a topologia.

### 4. Commits em português, conventional commits
- Formato: `tipo(escopo): mensagem em português`
- Tipos: `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `perf`, `test`
- Escopos: `piave`, `enemy`, `player`, `hud`, `terrain`, `env`, `ui`, `campaign`
- Exemplo: `feat(piave): sistema de rio procedural com segmentos curvos`

---

## 🎮 Sobre o Projeto

**Senta a Pua!** é um jogo de combate aéreo na Godot 4, ambientado na campanha do 1º Grupo de Aviação de Caça (1º GAvCa) da FAB na Itália durante a Segunda Guerra Mundial (1944-1945).

- **Engine:** Godot 4.7 (Forward+)
- **Linguagem:** GDScript
- **Direção de arte:** Low-poly estilizado com iluminação atmosférica
- **Assets:** Modelos Meshy AI (.glb) + Ultimate Nature Pack (Quaternius)
- **Cena principal:** `res://scenes/menu.tscn`
- **AutoLoad:** `GameManager` (`res://scripts/game_manager.gd`)

### Estrutura de diretórios
```
scenes/           # Cenas Godot (.tscn)
  missions/       # Cenas específicas de missão
  environment/    # Componentes de ambiente (ground, mountain, river, sky)
scripts/          # GDScripts
assets/           # Assets do jogo
  meshy/          # Modelos 3D gerados por Meshy AI (.glb + texturas)
  terrain/        # Assets de terreno (heightmaps, texturas, natureza)
assets_3d/        # Assets 3D importados (Quaternius Nature Pack)
docs/             # Documentação de design e descoberta
addons/           # Plugins Godot (godot-neovim, terrain_3d)
```

---

## 🔧 Convenções de Código

### Godot / GDScript
- Use `@export` para parâmetros ajustáveis no Inspector
- Prefira `CharacterBody3D` para entidades com física, `StaticBody3D` para objetos de cenário
- Sempre use `Area3D` ou sinais de colisão para dano, não dependa de `name` checks
- Use grupos (`add_to_group("enemy")`) para categorização
- `queue_free()` em vez de `free()` — sempre
- Verifique `is_instance_valid()` antes de acessar nós após potenciais `queue_free()`
- Prefira cenas autocontidas: cada cena de missão gera seu próprio ambiente, terreno e iluminação

### Modelos Meshy
- Modelos Meshy vêm rotacionados (face para cima em vez de frente). Corrigir com:
  ```gdscript
  model.rotation_degrees = Vector3(0, -90, 0)  # face forward (-Z)
  model.scale = Vector3(5, 5, 5)               # Meshy models are small
  ```
- Escala típica: aviões 5x, construções 3x, pontes 25x/12x/12x
- Texturas vêm como .jpg separados, importados automaticamente pelo Godot

### Física de Voo
- Forward direction = `-global_transform.basis.z`
- Lift = `global_transform.basis.y * 9.8 * speed_ratio`
- Gravity = `Vector3(0, -9.8, 0)`
- Velocidade: 20-65 m/s (~150-480 MPH na escala do HUD)

---

## 📖 Documentos de Referência

| Documento | Conteúdo |
|---|---|
| [`PLANO_DE_DESENVOLVIMENTO.md`](./PLANO_DE_DESENVOLVIMENTO.md) | Fases completas do desenvolvimento, progresso atual |
| [`docs/DISCOVERY_MISSAO1.md`](./docs/DISCOVERY_MISSAO1.md) | Pesquisa histórica e design da Missão 1 — Ponte de Piave |
| [`docs/PLANO_VISUAL.md`](./docs/PLANO_VISUAL.md) | Referências visuais e plano de refinamento artístico |
| [`docs/MESHY_PROMPTS.md`](./docs/MESHY_PROMPTS.md) | Prompts usados para gerar modelos 3D no Meshy AI |
| [`docs/ASSETS_LOWPOLY_PLAN.md`](./docs/ASSETS_LOWPOLY_PLAN.md) | Plano original de assets low-poly (pré-Meshy) |

---

## 🐛 Bugs Conhecidos (atualizados no plano)

Ver tabela de bugs no final do [`PLANO_DE_DESENVOLVIMENTO.md`](./PLANO_DE_DESENVOLVIMENTO.md).

---

## 🚀 Workflow de Desenvolvimento

1. **Consultar** o plano para ver o que deve ser feito em seguida
2. **Implementar** seguindo as convenções acima
3. **Testar** a funcionalidade no editor Godot
4. **Comitar** com mensagem em conventional commits
5. **Atualizar** o plano marcando checkboxes concluídos
6. Se a feature é significativa: adicionar nova fase ou expandir fase existente
