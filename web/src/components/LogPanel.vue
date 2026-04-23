<script setup lang="ts">
import type { RoundLog } from '@/engine/types'

defineProps<{
  entries: RoundLog[]
}>()
</script>

<template>
  <section class="log" aria-label="Spielprotokoll">
    <h2 class="h">Protokoll</h2>
    <ol class="list">
      <li v-for="e in [...entries].reverse()" :key="e.round + '-' + e.player" class="item">
        <span class="meta">Runde {{ e.round }} · {{ e.player === 'knutt' ? 'Knutt' : 'Herzmuschel' }}</span>
        <span class="d">Wurf ({{ e.diceX }}|{{ e.diceY }})</span>
        <span class="txt">{{ e.result }}</span>
      </li>
    </ol>
    <p v-if="entries.length === 0" class="empty">Noch keine Würfe.</p>
  </section>
</template>

<style scoped>
.log {
  background: rgba(255, 255, 255, 0.92);
  border-radius: 14px;
  padding: 1rem 1.25rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  max-height: 280px;
  display: flex;
  flex-direction: column;
}

.h {
  margin: 0 0 0.5rem;
  font-size: 1rem;
  color: #3d3228;
}

.list {
  list-style: none;
  margin: 0;
  padding: 0;
  overflow-y: auto;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
}

.item {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  font-size: 0.85rem;
}

.meta {
  font-weight: 700;
  color: #2c5f5f;
}

.d {
  color: #6b5b4f;
  font-size: 0.8rem;
}

.txt {
  color: #333;
  line-height: 1.35;
}

.empty {
  margin: 0.5rem 0 0;
  color: #888;
  font-size: 0.9rem;
}
</style>
