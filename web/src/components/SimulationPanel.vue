<script setup lang="ts">
import { ref } from 'vue'
import { storeToRefs } from 'pinia'
import { useGameStore } from '@/stores/game'
import PopulationChart from './PopulationChart.vue'

const game = useGameStore()
const { simulations, simulating, simulationProgress } = storeToRefs(game)

const count = ref(4)

function clamp() {
  if (Number.isNaN(count.value)) count.value = 1
  count.value = Math.max(1, Math.min(50, Math.floor(count.value)))
}

async function start() {
  clamp()
  await game.runSimulations(count.value)
}
</script>

<template>
  <section class="sim">
    <header class="sim-head">
      <div>
        <h2 class="h">Simulation</h2>
        <p class="sub">Spiele komplette Spiele (bis 400 Würfe / 20 Protokollpunkte) automatisch durch.</p>
      </div>
      <div class="controls">
        <label class="field">
          <span>Anzahl Spiele</span>
          <input
            v-model.number="count"
            type="number"
            min="1"
            max="50"
            step="1"
            inputmode="numeric"
            :disabled="simulating"
            @blur="clamp"
          />
        </label>
        <button type="button" class="btn primary" :disabled="simulating" @click="start">
          {{ simulating ? `Läuft… ${simulationProgress.current}/${simulationProgress.total}` : 'Simulieren' }}
        </button>
        <button
          type="button"
          class="btn secondary"
          :disabled="simulating || simulations.length === 0"
          @click="game.clearSimulations()"
        >
          Leeren
        </button>
      </div>
    </header>

    <div v-if="simulations.length === 0 && !simulating" class="empty">
      Noch keine Simulation gestartet.
    </div>

    <div v-else class="grid">
      <article v-for="run in simulations" :key="run.id" class="card">
        <header class="card-head">
          <h3>Spiel {{ run.id }}</h3>
          <span class="meta">
            {{ run.turns }} Würfe ({{ run.rounds }} Runden) · Ende: Knutt {{ run.finalKnutt }} / Muschel {{ run.finalMuschel }}
          </span>
        </header>
        <div class="chart-slot">
          <PopulationChart :snapshots="run.snapshots" :compact="true" />
        </div>
      </article>
    </div>
  </section>
</template>

<style scoped>
.sim {
  background: rgba(255, 255, 255, 0.92);
  border-radius: 14px;
  padding: 1rem 1.25rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.sim-head {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: flex-end;
  justify-content: space-between;
}

.h {
  margin: 0;
  font-size: 1.1rem;
  color: #3d3228;
}

.sub {
  margin: 0.25rem 0 0;
  font-size: 0.88rem;
  color: #6b5b4f;
}

.controls {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  align-items: flex-end;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  font-size: 0.8rem;
  color: #4a3728;
  font-weight: 600;
}

.field input {
  width: 5.5rem;
  padding: 0.45rem 0.55rem;
  border-radius: 8px;
  border: 1px solid rgba(0, 0, 0, 0.18);
  font-size: 1rem;
  font-weight: 600;
  background: #fff;
}

.field input:disabled {
  background: #f0ece6;
}

.btn {
  border: none;
  border-radius: 10px;
  padding: 0.55rem 1rem;
  font-weight: 700;
  cursor: pointer;
}

.btn.primary {
  background: #008b8b;
  color: #fff;
  box-shadow: 0 3px 0 #006b6b;
}

.btn.secondary {
  background: #fff;
  color: #1e4d4b;
  border: 2px solid #008b8b;
}

.btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  box-shadow: none;
}

.empty {
  color: #888;
  font-size: 0.95rem;
  text-align: center;
  padding: 1rem;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 0.85rem;
}

.card {
  background: #fffdf8;
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-radius: 12px;
  padding: 0.65rem 0.75rem 0.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.card-head {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  justify-content: space-between;
  gap: 0.35rem;
}

.card-head h3 {
  margin: 0;
  font-size: 0.95rem;
  color: #2c5f5f;
}

.meta {
  font-size: 0.75rem;
  color: #6b5b4f;
}

.chart-slot {
  height: 180px;
}
</style>
