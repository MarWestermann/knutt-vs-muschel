<script setup lang="ts">
import type { TileKind } from '@/engine/types'

defineProps<{
  current: TileKind
  knutt: number
  muschel: number
  labelFor: (p: TileKind) => string
  gameOver: boolean
  skipRounds: number
}>()
</script>

<template>
  <section class="panel" aria-live="polite">
    <h2 class="h">Population</h2>
    <ul class="stats">
      <li :class="{ active: current === 'knutt' && !gameOver }">
        <img src="/assets/knutt.png" alt="" class="ico" />
        <span class="name">Knutt</span>
        <strong>{{ knutt }}</strong>
      </li>
      <li :class="{ active: current === 'muschel' && !gameOver }">
        <img src="/assets/muschel.png" alt="" class="ico" />
        <span class="name">Herzmuschel</span>
        <strong>{{ muschel }}</strong>
      </li>
    </ul>
    <p v-if="!gameOver" class="turn">
      Am Zug: <strong>{{ labelFor(current) }}</strong>
    </p>
    <p v-else class="turn done">Spiel beendet</p>
    <p v-if="skipRounds > 0" class="skip">Pause Herzmuschel-Vermehrung: {{ skipRounds }}</p>
  </section>
</template>

<style scoped>
.panel {
  background: rgba(255, 255, 255, 0.88);
  border-radius: 14px;
  padding: 1rem 1.25rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  max-width: 22rem;
}

.h {
  margin: 0 0 0.75rem;
  font-size: 1rem;
  color: #3d3228;
}

.stats {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.stats li {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.4rem 0.5rem;
  border-radius: 10px;
  border: 2px solid transparent;
}

.stats li.active {
  border-color: #008b8b;
  background: rgba(0, 139, 139, 0.08);
}

.ico {
  width: 2rem;
  height: 2rem;
  object-fit: contain;
}

.name {
  flex: 1;
  font-weight: 600;
  color: #4a3728;
}

.turn {
  margin: 0.85rem 0 0;
  font-size: 0.95rem;
  color: #4a3728;
}

.turn.done {
  color: #8b4513;
}

.skip {
  margin: 0.5rem 0 0;
  font-size: 0.85rem;
  color: #a0522d;
}
</style>
