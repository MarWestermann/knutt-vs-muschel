<script setup lang="ts">
import type { Cell as CellValue } from '@/engine/types'

defineProps<{
  cell: CellValue
}>()
</script>

<template>
  <div class="cell">
    <img v-if="cell === 'knutt'" class="token" src="/assets/knutt.png" alt="Knutt" />
    <img v-else-if="cell === 'muschel'" class="token" src="/assets/muschel.png" alt="Herzmuschel" />
  </div>
</template>

<style scoped>
.cell {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.token {
  width: 78%;
  height: 78%;
  object-fit: contain;
  filter: drop-shadow(0 2px 3px rgba(0, 0, 0, 0.25));
  animation: pop 0.35s ease-out;
}

@keyframes pop {
  from {
    transform: scale(0.6);
    opacity: 0.5;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}
</style>
