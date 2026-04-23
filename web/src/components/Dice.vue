<script setup lang="ts">
defineProps<{
  x: number | null
  y: number | null
  rolling?: boolean
}>()

const face = (n: number | null) => (n === null ? '–' : String(n))
</script>

<template>
  <div class="dice-row">
    <div class="pair">
      <span class="lbl">Spalte (x)</span>
      <div class="die" :class="{ shake: rolling }" :aria-label="'Würfel x ' + face(x)">
        {{ face(x) }}
      </div>
    </div>
    <div class="pair">
      <span class="lbl">Zeile (y)</span>
      <div class="die" :class="{ shake: rolling }" :aria-label="'Würfel y ' + face(y)">
        {{ face(y) }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.dice-row {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  justify-content: center;
  gap: 1.25rem;
}

.pair {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.35rem;
}

.lbl {
  font-size: 0.8rem;
  font-weight: 600;
  color: #4a3728;
}

.die {
  width: 3.5rem;
  height: 3.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.75rem;
  font-weight: 800;
  color: #1a1a1a;
  background: linear-gradient(145deg, #fff8f0, #e8dcc8);
  border-radius: 12px;
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.8),
    0 4px 0 #b8a990,
    0 6px 12px rgba(0, 0, 0, 0.12);
}

.die.shake {
  animation: wobble 0.45s ease-in-out infinite;
}

@keyframes wobble {
  0%,
  100% {
    transform: rotate(-5deg) scale(1.02);
  }
  50% {
    transform: rotate(5deg) scale(1.02);
  }
}
</style>
