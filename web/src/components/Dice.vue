<script setup lang="ts">
import { computed, ref, watch } from 'vue'

const props = defineProps<{
  x: number | null
  y: number | null
  rolling?: boolean
}>()

/**
 * Liefert die Cube-Rotation, die nötig ist, damit die angegebene Augenzahl
 * nach vorne zeigt. Die Faces sind so platziert, dass gegenüberliegende
 * Augenzahlen wie bei einem echten Würfel zusammen 7 ergeben (1↔6, 2↔5, 3↔4).
 */
function faceTransform(n: number | null): string {
  switch (n) {
    case 1:
      return 'rotateX(0deg) rotateY(0deg)'
    case 2:
      return 'rotateY(-90deg)'
    case 3:
      return 'rotateX(-90deg)'
    case 4:
      return 'rotateX(90deg)'
    case 5:
      return 'rotateY(90deg)'
    case 6:
      return 'rotateY(180deg)'
    default:
      return 'rotateX(-20deg) rotateY(25deg)'
  }
}

/**
 * Pip-Positionen je Augenzahl in einem 3x3-Raster (1..9, von oben-links).
 * 1 2 3
 * 4 5 6
 * 7 8 9
 */
const PIP_LAYOUT: Record<number, number[]> = {
  1: [5],
  2: [1, 9],
  3: [1, 5, 9],
  4: [1, 3, 7, 9],
  5: [1, 3, 5, 7, 9],
  6: [1, 3, 4, 6, 7, 9],
}

const FACES = [1, 2, 3, 4, 5, 6] as const

/**
 * Damit wir bei jedem neuen Wurf eine frische Tumble-Animation bekommen
 * (auch wenn zwei Mal in Folge die gleiche Zahl kommt), erhöhen wir bei
 * jeder steigenden Flanke von "rolling" einen Counter und nutzen ihn als
 * Vue-`:key`. Außerdem variieren wir die Animations­parameter pro Wurf
 * leicht, damit jeder Wurf etwas anders aussieht.
 */
const rollNonce = ref(0)
const xWobble = ref({ rx: 720, ry: 1080, rz: 360 })
const yWobble = ref({ rx: 1080, ry: 720, rz: -360 })

function randomTumble() {
  const sign = () => (Math.random() < 0.5 ? -1 : 1)
  const spin = () => (2 + Math.floor(Math.random() * 3)) * 360 * sign()
  return { rx: spin(), ry: spin(), rz: spin() / 2 }
}

watch(
  () => props.rolling,
  (now, prev) => {
    if (now && !prev) {
      rollNonce.value += 1
      xWobble.value = randomTumble()
      yWobble.value = randomTumble()
    }
  },
)

const xStyle = computed(() => ({
  '--tumble-rx': xWobble.value.rx + 'deg',
  '--tumble-ry': xWobble.value.ry + 'deg',
  '--tumble-rz': xWobble.value.rz + 'deg',
  transform: props.rolling ? undefined : faceTransform(props.x),
}))

const yStyle = computed(() => ({
  '--tumble-rx': yWobble.value.rx + 'deg',
  '--tumble-ry': yWobble.value.ry + 'deg',
  '--tumble-rz': yWobble.value.rz + 'deg',
  transform: props.rolling ? undefined : faceTransform(props.y),
}))

const ariaX = computed(() =>
  props.x === null ? 'Würfel Spalte: noch nicht geworfen' : 'Würfel Spalte ' + props.x,
)
const ariaY = computed(() =>
  props.y === null ? 'Würfel Zeile: noch nicht geworfen' : 'Würfel Zeile ' + props.y,
)
</script>

<template>
  <div class="dice-row">
    <div class="pair">
      <span class="lbl">Spalte (x)</span>
      <div class="stage" :class="{ rolling }">
        <div class="shadow" :class="{ rolling }" />
        <div class="cube-wrap" :class="{ rolling }">
          <div
            :key="'x-' + rollNonce"
            class="cube tint-x"
            :class="{ rolling }"
            :style="xStyle"
            :aria-label="ariaX"
            role="img"
          >
            <div v-for="n in FACES" :key="n" class="face" :class="'face-' + n">
              <span
                v-for="pos in PIP_LAYOUT[n]"
                :key="pos"
                class="pip"
                :class="'pos-' + pos"
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="pair">
      <span class="lbl">Zeile (y)</span>
      <div class="stage" :class="{ rolling }">
        <div class="shadow" :class="{ rolling }" />
        <div class="cube-wrap delayed" :class="{ rolling }">
          <div
            :key="'y-' + rollNonce"
            class="cube tint-y"
            :class="{ rolling }"
            :style="yStyle"
            :aria-label="ariaY"
            role="img"
          >
            <div v-for="n in FACES" :key="n" class="face" :class="'face-' + n">
              <span
                v-for="pos in PIP_LAYOUT[n]"
                :key="pos"
                class="pip"
                :class="'pos-' + pos"
              />
            </div>
          </div>
        </div>
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
  gap: 1.75rem;
  padding: 0.5rem 0 0.25rem;
}

.pair {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.4rem;
}

.lbl {
  font-size: 0.8rem;
  font-weight: 600;
  color: #4a3728;
}

/* Bühne mit Perspektive – sorgt für die räumliche Wirkung. */
.stage {
  --size: 4rem;
  position: relative;
  width: var(--size);
  height: calc(var(--size) + 0.9rem);
  perspective: 600px;
  perspective-origin: 50% 35%;
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

/* Bodenschatten unter dem Würfel */
.shadow {
  position: absolute;
  bottom: 0.05rem;
  left: 50%;
  width: calc(var(--size) * 0.95);
  height: 0.55rem;
  transform: translateX(-50%);
  background: radial-gradient(
    ellipse at center,
    rgba(0, 0, 0, 0.32) 0%,
    rgba(0, 0, 0, 0.12) 55%,
    rgba(0, 0, 0, 0) 75%
  );
  filter: blur(1px);
  border-radius: 50%;
  transition: transform 0.25s ease, opacity 0.25s ease;
}

.shadow.rolling {
  animation: shadow-pulse 0.55s ease-in-out infinite;
}

/* Wrapper, der die "Wurf-Hopser" (Höhe) übernimmt – getrennt von der Cube-Rotation. */
.cube-wrap {
  position: relative;
  width: var(--size);
  height: var(--size);
  transform-style: preserve-3d;
}

.cube-wrap.rolling {
  animation: bounce 0.55s cubic-bezier(0.4, 0, 0.2, 1) infinite;
}

.cube-wrap.delayed.rolling {
  animation-delay: 0.08s;
}

/* Der eigentliche 3D-Würfel. Wenn er nicht rollt, wird per inline-Transform
   die Endlage gesetzt; der Übergang sorgt für ein weiches "Einrasten". */
.cube {
  position: absolute;
  inset: 0;
  transform-style: preserve-3d;
  transform: rotateX(-20deg) rotateY(25deg);
  transition: transform 0.45s cubic-bezier(0.2, 0.9, 0.3, 1.4);
  will-change: transform;
}

.cube.rolling {
  animation: tumble 0.55s linear infinite;
  transition: none;
}

/* Sechs Seiten des Würfels – jeweils um halbe Kantenlänge nach außen verschoben. */
.face {
  position: absolute;
  inset: 0;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-template-rows: repeat(3, 1fr);
  padding: 10%;
  gap: 3%;
  border-radius: 14%;
  background:
    radial-gradient(circle at 30% 25%, rgba(255, 255, 255, 0.85), rgba(255, 255, 255, 0) 55%),
    linear-gradient(150deg, #fffaf0 0%, #f1e6cf 60%, #d9c9a8 100%);
  box-shadow:
    inset 0 0 0 1px rgba(120, 95, 60, 0.35),
    inset 0 -4px 8px rgba(120, 90, 50, 0.18),
    inset 0 4px 8px rgba(255, 255, 255, 0.55);
  backface-visibility: hidden;
}

/* Sanfte Tönung pro Würfel, damit klar ist, welcher zu welcher Achse gehört. */
.cube.tint-x .face {
  background:
    radial-gradient(circle at 30% 25%, rgba(255, 255, 255, 0.85), rgba(255, 255, 255, 0) 55%),
    linear-gradient(150deg, #fff5ec 0%, #f3dcc2 55%, #d6b48a 100%);
}

.cube.tint-y .face {
  background:
    radial-gradient(circle at 30% 25%, rgba(255, 255, 255, 0.85), rgba(255, 255, 255, 0) 55%),
    linear-gradient(150deg, #f4f9f5 0%, #d8ebd8 55%, #a9c8b0 100%);
}

.face-1 {
  transform: translateZ(calc(var(--size) / 2));
}
.face-2 {
  transform: rotateY(90deg) translateZ(calc(var(--size) / 2));
}
.face-3 {
  transform: rotateX(90deg) translateZ(calc(var(--size) / 2));
}
.face-4 {
  transform: rotateX(-90deg) translateZ(calc(var(--size) / 2));
}
.face-5 {
  transform: rotateY(-90deg) translateZ(calc(var(--size) / 2));
}
.face-6 {
  transform: rotateY(180deg) translateZ(calc(var(--size) / 2));
}

/* Pip-Augen */
.pip {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  align-self: center;
  justify-self: center;
  background: radial-gradient(
    circle at 35% 30%,
    #5a4326 0%,
    #2b1a0c 55%,
    #0d0703 100%
  );
  box-shadow:
    inset 0 1px 1px rgba(255, 255, 255, 0.25),
    inset 0 -1px 2px rgba(0, 0, 0, 0.5);
}

.cube.tint-x .pip {
  background: radial-gradient(circle at 35% 30%, #6b2a1a 0%, #3a0f08 55%, #170504 100%);
}

.cube.tint-y .pip {
  background: radial-gradient(circle at 35% 30%, #1f4a2a 0%, #0c2614 55%, #051208 100%);
}

/* Pip-Position im 3x3-Raster */
.pos-1 {
  grid-column: 1;
  grid-row: 1;
}
.pos-2 {
  grid-column: 2;
  grid-row: 1;
}
.pos-3 {
  grid-column: 3;
  grid-row: 1;
}
.pos-4 {
  grid-column: 1;
  grid-row: 2;
}
.pos-5 {
  grid-column: 2;
  grid-row: 2;
}
.pos-6 {
  grid-column: 3;
  grid-row: 2;
}
.pos-7 {
  grid-column: 1;
  grid-row: 3;
}
.pos-8 {
  grid-column: 2;
  grid-row: 3;
}
.pos-9 {
  grid-column: 3;
  grid-row: 3;
}

/* Animationen */
@keyframes tumble {
  0% {
    transform: rotateX(0) rotateY(0) rotateZ(0);
  }
  100% {
    transform: rotateX(var(--tumble-rx)) rotateY(var(--tumble-ry)) rotateZ(var(--tumble-rz));
  }
}

@keyframes bounce {
  0% {
    transform: translateY(0);
  }
  35% {
    transform: translateY(-1.4rem);
  }
  70% {
    transform: translateY(-0.2rem);
  }
  100% {
    transform: translateY(0);
  }
}

@keyframes shadow-pulse {
  0% {
    transform: translateX(-50%) scale(1);
    opacity: 0.9;
  }
  35% {
    transform: translateX(-50%) scale(0.55);
    opacity: 0.45;
  }
  70% {
    transform: translateX(-50%) scale(0.85);
    opacity: 0.7;
  }
  100% {
    transform: translateX(-50%) scale(1);
    opacity: 0.9;
  }
}

@media (prefers-reduced-motion: reduce) {
  .cube.rolling,
  .cube-wrap.rolling,
  .shadow.rolling {
    animation: none !important;
  }
  .cube {
    transition: none;
  }
}
</style>
