<script setup lang="ts">
import Cell from './Cell.vue'
import type { Board } from '@/engine/types'

defineProps<{
  board: Board
  highlight?: { x: number; y: number } | null
}>()

const headers = [1, 2, 3, 4, 5, 6]
</script>

<template>
  <div class="board-frame">
    <h2 class="title">Spielfeld</h2>

    <div class="board-grid" role="grid" aria-label="Spielfeld 6 mal 6">
      <div class="corner" aria-hidden="true" />
      <div
        v-for="x in headers"
        :key="'cx-' + x"
        class="header header-x"
        role="columnheader"
      >
        {{ x }}
      </div>

      <template v-for="y in headers" :key="'row-' + y">
        <div class="header header-y" role="rowheader">{{ y }}</div>
        <div
          v-for="x in headers"
          :key="'cell-' + x + '-' + y"
          class="cell-slot"
          :class="{ active: highlight && highlight.x === x && highlight.y === y }"
          role="gridcell"
          :aria-label="`Feld ${x} ${y}`"
        >
          <Cell :cell="board[y - 1]?.[x - 1] ?? null" />
        </div>
      </template>
    </div>

    <p class="caption">
      Im Wattenmeer treffen Knutt und Herzmuschel u. a. aufeinander.
      In der Realität kommen weitere Faktoren dazu.
    </p>
  </div>
</template>

<style scoped>
.board-frame {
  --frame-bg: linear-gradient(160deg, #f4e4c1 0%, #e7d2a3 60%, #d8bf86 100%);
  --header-x-bg: #ec3f8a;
  --header-y-bg: #ffd400;
  --header-text: #1a1a1a;
  --cell-bg: #1a8c8a;
  --cell-bg-active: #25b5b3;
  --frame-text: #5a3a1f;

  position: relative;
  width: min(94vw, calc(560px + 3cm));
  margin: 0 auto;
  padding: 1rem 1rem 0.85rem;
  background: var(--frame-bg);
  border-radius: 18px;
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.35),
    0 8px 24px rgba(0, 0, 0, 0.15);
}

.title {
  margin: 0 0 0.6rem 0.4rem;
  font-family: 'Georgia', 'Times New Roman', serif;
  font-style: italic;
  font-weight: 700;
  font-size: 1.6rem;
  color: var(--frame-text);
  letter-spacing: 0.02em;
}

.board-grid {
  display: grid;
  /* erste Spalte = Y-Header, Rest = 6 Zellen; erste Zeile = X-Header */
  grid-template-columns: minmax(1.6rem, 0.55fr) repeat(6, 1fr);
  grid-template-rows: minmax(1.6rem, 0.55fr) repeat(6, 1fr);
  gap: 0.45rem;
  aspect-ratio: 6.55 / 6.55;
}

.corner {
  background: transparent;
}

.header {
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  font-size: clamp(0.85rem, 2.2vw, 1.05rem);
  color: var(--header-text);
  border-radius: 999px;
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.5),
    0 1px 2px rgba(0, 0, 0, 0.12);
  user-select: none;
  min-width: 0;
  min-height: 0;
}

.header-x {
  background: var(--header-x-bg);
  color: #fff;
}

.header-y {
  background: var(--header-y-bg);
}

.cell-slot {
  position: relative;
  background: var(--cell-bg);
  border-radius: 12px;
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.18),
    inset 0 -3px 0 rgba(0, 0, 0, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 0;
  min-height: 0;
  transition: background-color 0.18s ease, transform 0.18s ease;
}

.cell-slot.active {
  background: var(--cell-bg-active);
  transform: scale(1.04);
  box-shadow:
    inset 0 0 0 2px #fff,
    0 0 0 3px rgba(236, 63, 138, 0.65);
}

.caption {
  margin: 0.85rem 0.25rem 0;
  font-family: 'Georgia', 'Times New Roman', serif;
  font-style: italic;
  font-size: 0.85rem;
  line-height: 1.35;
  color: var(--frame-text);
  text-align: center;
}

@media (max-width: 480px) {
  .board-frame {
    padding: 0.75rem 0.6rem 0.6rem;
  }
  .title {
    font-size: 1.3rem;
  }
  .board-grid {
    gap: 0.3rem;
  }
}
</style>
