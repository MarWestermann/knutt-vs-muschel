<script setup lang="ts">
import { ref } from 'vue'
import { storeToRefs } from 'pinia'
import { useGameStore } from '@/stores/game'
import Board from '@/components/Board.vue'
import Dice from '@/components/Dice.vue'
import PlayerPanel from '@/components/PlayerPanel.vue'
import LogPanel from '@/components/LogPanel.vue'
import PopulationChart from '@/components/PopulationChart.vue'
import RuleHelp from '@/components/RuleHelp.vue'

const game = useGameStore()
const {
  state,
  lastDice,
  rolling,
  knuttCount,
  muschelCount,
  currentPlayer,
  round,
  gameOver,
  gameOverReason,
  history,
  snapshots,
  musselSkipRounds,
  canRoll,
} = storeToRefs(game)

const tab = ref<'log' | 'chart'>('log')
const rulesOpen = ref(false)
</script>

<template>
  <div class="app">
    <header class="hero">
      <div class="titles">
        <h1>Knutt vs. Herzmuschel</h1>
        <p class="sub">Räuber–Beute im Wattenmeer · Hot-Seat für zwei Spieler:innen</p>
      </div>
      <div class="actions">
        <button type="button" class="btn secondary" @click="rulesOpen = true">Regeln</button>
        <button type="button" class="btn" @click="game.newGame()">Neues Spiel</button>
      </div>
    </header>

    <main class="layout">
      <div class="col board-col">
        <Board :board="state.board" />
        <p class="meta">Wurf {{ round }} / 200 · Protokollpunkte: {{ snapshots.length }} / 20</p>
      </div>

      <aside class="col side">
        <PlayerPanel
          :current="currentPlayer"
          :knutt="knuttCount"
          :muschel="muschelCount"
          :label-for="game.labelForPlayer"
          :game-over="gameOver"
          :skip-rounds="musselSkipRounds"
        />

        <div class="dice-card">
          <Dice :x="lastDice?.x ?? null" :y="lastDice?.y ?? null" :rolling="rolling" />
          <button type="button" class="btn roll" :disabled="!canRoll || rolling" @click="game.rollDice()">
            {{ rolling ? 'Würfelt…' : 'Würfeln' }}
          </button>
        </div>

        <div v-if="gameOver" class="banner" role="status">
          <strong>Ende.</strong> {{ gameOverReason }}
        </div>

        <div class="tabs">
          <button type="button" :class="{ on: tab === 'log' }" @click="tab = 'log'">Protokoll</button>
          <button type="button" :class="{ on: tab === 'chart' }" @click="tab = 'chart'">Diagramm</button>
        </div>

        <LogPanel v-show="tab === 'log'" :entries="history" />
        <PopulationChart v-show="tab === 'chart'" :snapshots="snapshots" />
      </aside>
    </main>

    <RuleHelp :open="rulesOpen" @close="rulesOpen = false" />
  </div>
</template>

<style scoped>
.app {
  min-height: 100vh;
  padding: 1rem clamp(0.75rem, 3vw, 2rem) 2rem;
  background: linear-gradient(180deg, #e8f4f2 0%, #f5efe6 45%, #ebe4d8 100%);
}

.hero {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1.25rem;
}

.titles h1 {
  margin: 0;
  font-size: clamp(1.35rem, 4vw, 2rem);
  color: #1e4d4b;
  letter-spacing: -0.02em;
}

.sub {
  margin: 0.35rem 0 0;
  color: #4a5f5e;
  font-size: 0.95rem;
}

.actions {
  display: flex;
  gap: 0.5rem;
}

.layout {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.25rem;
  align-items: start;
}

@media (min-width: 960px) {
  .layout {
    grid-template-columns: minmax(0, 1fr) 320px;
  }
}

.board-col {
  width: 100%;
}

.meta {
  text-align: center;
  margin: 0.5rem 0 0;
  font-size: 0.88rem;
  color: #4a5f5e;
}

.side {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.dice-card {
  background: rgba(255, 255, 255, 0.88);
  border-radius: 14px;
  padding: 1rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
}

.tabs {
  display: flex;
  gap: 0.35rem;
}

.tabs button {
  flex: 1;
  border: 1px solid rgba(0, 0, 0, 0.12);
  background: rgba(255, 255, 255, 0.6);
  padding: 0.45rem 0.5rem;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  color: #4a3728;
}

.tabs button.on {
  background: #008b8b;
  color: #fff;
  border-color: #007070;
}

.banner {
  background: #fff3cd;
  border: 1px solid #e0c36a;
  color: #5c4813;
  padding: 0.65rem 0.85rem;
  border-radius: 10px;
  font-size: 0.9rem;
}

.btn {
  border: none;
  border-radius: 10px;
  padding: 0.55rem 1rem;
  font-weight: 700;
  cursor: pointer;
  background: #008b8b;
  color: #fff;
  box-shadow: 0 3px 0 #006b6b;
}

.btn.secondary {
  background: #fff;
  color: #1e4d4b;
  border: 2px solid #008b8b;
  box-shadow: none;
}

.btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.btn.roll {
  width: 100%;
  max-width: 14rem;
  font-size: 1rem;
  padding: 0.65rem 1rem;
}
</style>
