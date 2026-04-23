<script setup lang="ts">
import { computed } from 'vue'
import Cell from './Cell.vue'
import type { Board } from '@/engine/types'

const props = defineProps<{
  board: Board
}>()

const rows = computed(() => props.board)
</script>

<template>
  <div class="board-wrap">
    <div class="board-bg" aria-hidden="true" />
    <div class="grid-overlay">
      <div v-for="(row, ri) in rows" :key="ri" class="row">
        <div v-for="(cell, ci) in row" :key="ci" class="grid-cell">
          <Cell :cell="cell" />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.board-wrap {
  position: relative;
  width: min(92vw, 560px);
  margin: 0 auto;
}

.board-bg {
  width: 100%;
  aspect-ratio: 1 / 1;
  background: url('/assets/spielfeld.png') center / contain no-repeat;
  border-radius: 12px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.grid-overlay {
  position: absolute;
  /* Werte grob an das Grafik-Spielfeld angepasst (6×6 Zellen) */
  top: 18%;
  left: 11%;
  right: 11%;
  bottom: 22%;
  display: flex;
  flex-direction: column;
  gap: 1.5%;
}

.row {
  display: flex;
  flex: 1;
  gap: 1.5%;
  min-height: 0;
}

.grid-cell {
  flex: 1;
  min-width: 0;
  min-height: 0;
}
</style>
