# Missão 1 — Batismo de Fogo: Ponte do Piave

**Status:** Em desenvolvimento  
**Campanha:** Itália (1944)  
**Tipo de missão:** Interdição (Armed Reconnaissance / Interdiction)

---

## Objetivo da Missão

Introduzir o jogador ao fluxo de combate de Senta a Púa!, apresentando o papel histórico do 1º Grupo de Aviação de Caça na campanha da Itália.

A missão deve transmitir a sensação de participar de uma operação militar real, onde a prioridade é interromper a logística alemã, e não simplesmente destruir inimigos.

O combate deve surgir naturalmente como consequência da missão.

---

## Contexto Histórico

Final de 1944. As forças alemãs recuam em direção à Linha Gótica enquanto tentam manter abertas as rotas ferroviárias e rodoviárias do norte da Itália. Uma das ligações mais importantes atravessa o Rio Piave.

Relatórios de inteligência aliados indicam intensa movimentação de suprimentos utilizando a ferrovia da região. O 1º Grupo de Aviação de Caça recebe a missão de interromper esse fluxo antes que os reforços consigam alcançar as posições defensivas alemãs.

---

## Fantasia do Jogador

O jogador deve sentir que está:
- Voando um P-47 Thunderbolt pesado e poderoso
- Procurando um alvo real dentro de um vale italiano
- Tomando decisões sob fogo antiaéreo
- Atacando infraestrutura crítica
- Escapando antes que a reação inimiga se organize

O foco não é vencer um dogfight. O foco é cumprir uma missão.

---

## Filosofia da Missão

O jogador não está participando de uma arena. Ele está executando uma operação militar.

Os inimigos existem porque defendem um objetivo estratégico. O combate é consequência da missão. A missão não é consequência do combate.

---

## Fluxo da Missão

```
Menu → Briefing → Decolagem → Navegação → Reconhecimento
→ Supressão das Defesas → Ataque à Ponte → Reação Alemã
→ Retirada → Debriefing
```

---

## Diretrizes de Gameplay

O jogador nunca deve receber uma lista artificial como:
- "Destrua 2 Flaks"
- "Destrua 2 aviões"
- "Destrua a ponte"

Em vez disso, os objetivos devem evoluir conforme a situação da missão.

---

## Estados da Missão

### Estado 1 — Decolagem

**Objetivo:** Decolar da base.

**Gameplay:**
- Introdução aos controles
- Tempo para ganhar altitude
- Nenhum combate

**Rádio:**  
_"Senta a Púa, aqui Controle. Inteligência informa movimentação ferroviária inimiga sobre o Rio Piave. Sua missão é interromper esse tráfego."_

**Checkpoint:** Após decolar.

---

### Estado 2 — Navegação

**Objetivo:** Seguir até a região do Piave.

**Gameplay:** O jogador sobrevoa pequenas fazendas, vilarejos, campos agrícolas, rios, montanhas ao fundo. Sem combate. O objetivo é criar expectativa.

**Rádio:** _"Mantenha o rumo. O alvo deve estar a poucos minutos."_

---

### Estado 3 — Reconhecimento

**Objetivo:** Localizar a ponte ferroviária.

**Gameplay:** Ao entrar na área da missão a ponte torna-se visível, fumaça da locomotiva pode ser vista ao longe, posições de Flak são identificadas. O jogador ainda pode escolher como iniciar o ataque.

**Rádio:** _"Alvo localizado."_

**Checkpoint:** Ao localizar a ponte.

---

### Estado 4 — Supressão das Defesas

**Objetivo Principal:** Abrir uma janela segura para atacar a ponte.

**Gameplay:** As posições Flak passam a representar o maior perigo. O jogador pode atacar as baterias, realizar múltiplas passagens, utilizar terreno e velocidade para sobreviver.

**Vitória do Estado:** Quando existir uma rota razoavelmente segura para atacar o objetivo principal. Não é obrigatório destruir todas as posições antiaéreas.

---

### Estado 5 — Ataque ao Objetivo Principal

**Objetivo:** Tornar a ponte inoperante.

**Gameplay:** O jogador mergulha sobre o alvo. Alvos possíveis: pilares, tabuleiro, locomotiva, vagões. Eventos visuais: fumaça, incêndios, explosões, partes da ponte desabando.

**Rádio:** _"Bom impacto! Continue o ataque!"_

**Checkpoint:** Após dano significativo à ponte.

---

### Estado 6 — Reação Alemã

**Objetivo:** Sobreviver e concluir a missão.

**Gameplay:** Dependendo do andamento da missão: caças inimigos podem chegar, caminhões tentam escapar, artilharia restante continua ativa. Os caças não são o objetivo principal — são uma resposta ao ataque aliado.

---

### Estado 7 — Romper Contato

**Objetivo:** Sair da área da missão.

**Gameplay:** Após cumprir os objetivos principais o jogador recebe ordem de retirada, ainda pode ser perseguido, não é necessário eliminar todos os inimigos.

**Rádio:** _"Objetivo neutralizado. Rompa contato e retorne."_

**Checkpoint:** Ao deixar a área operacional.

---

### Estado 8 — Debriefing

Resumo da missão:
- Ponte ferroviária: Destruída
- Locomotiva: Destruída
- Vagões: 3/5
- Flak neutralizadas: 2/3
- Caminhões destruídos: 4/6
- Aeronaves abatidas: 1
- Integridade do P-47: 63%
- Tempo da missão

**Resultado operacional:** A ferrovia foi inutilizada. O avanço logístico alemão foi atrasado.

---

## Objetivos

### Primários
- [ ] Decolar
- [ ] Localizar a ponte
- [ ] Tornar a ponte inoperante
- [ ] Retornar em segurança

### Secundários
- [ ] Neutralizar posições Flak
- [ ] Destruir a locomotiva
- [ ] Destruir vagões
- [ ] Destruir caminhões de suprimentos

### Opcionais
- [ ] Abater aeronaves inimigas
- [ ] Sofrer poucos danos
- [ ] Concluir rapidamente

---

## Eventos Dinâmicos

A missão deve parecer viva. Possíveis eventos:
- Trem começa a atravessar a ponte
- Caminhões tentam fugir
- Caças decolam após o ataque
- Uma Flak permanece escondida
- Coluna de fumaça visível a quilômetros
- Mensagens de rádio conforme o progresso

Nenhum evento deve parecer "spawnado". Eles devem ser consequência das ações do jogador.

---

## Progresso da Implementação

| Estado | Status |
|---|---|
| 1. Decolagem | 🔄 Em andamento |
| 2. Navegação | ⏳ Pendente |
| 3. Reconhecimento | ⏳ Pendente |
| 4. Supressão das Defesas | ⏳ Pendente |
| 5. Ataque à Ponte | ⏳ Pendente |
| 6. Reação Alemã | ⏳ Pendente |
| 7. Romper Contato | ⏳ Pendente |
| 8. Debriefing | ⏳ Pendente |
