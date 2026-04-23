import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { applyMove, countTiles, rollDie } from '@/engine/rules'
import { createInitialState, createMulberry32 } from '@/engine/setup'
import type { GameState, PopulationSnapshot, TileKind } from '@/engine/types'

export interface SimulationRun {
  id: number
  seed: number
  snapshots: PopulationSnapshot[]
  rounds: number
  finalKnutt: number
  finalMuschel: number
}

export const useGameStore = defineStore('game', () => {
  const rngSeed = ref(Math.floor(Math.random() * 0xffffffff))
  /** Fortlaufender Zähler für deterministische Würfel-Streams pro Zug */
  const rollSeq = ref(0)

  const state = ref<GameState>(createInitialState(createMulberry32(rngSeed.value)))

  const lastDice = ref<{ x: number; y: number } | null>(null)
  const rolling = ref(false)

  const simulations = ref<SimulationRun[]>([])
  const simulating = ref(false)
  const simulationProgress = ref({ current: 0, total: 0 })

  function mix32(a: number, b: number): number {
    return (Math.imul(a ^ b, 0x9e3779b9) >>> 0) ^ a
  }

  /** Spielt ein komplettes Spiel bis zum Ende und liefert das End-State */
  function simulateFullGame(seed: number): GameState {
    const initRng = createMulberry32(seed)
    let s = createInitialState(initRng)
    let safety = 0
    while (!s.gameOver && safety < 1000) {
      const stepRng = createMulberry32(mix32(seed, safety + 1))
      const dx = rollDie(stepRng)
      const dy = rollDie(stepRng)
      s = applyMove(s, dx, dy, stepRng).state
      safety++
    }
    return s
  }

  const knuttCount = computed(() => countTiles(state.value.board, 'knutt'))
  const muschelCount = computed(() => countTiles(state.value.board, 'muschel'))
  const currentPlayer = computed(() => state.value.currentPlayer)
  const round = computed(() => state.value.round)
  const gameOver = computed(() => state.value.gameOver)
  const gameOverReason = computed(() => state.value.gameOverReason)
  const history = computed(() => state.value.history)
  const snapshots = computed(() => state.value.snapshots)
  const musselSkipRounds = computed(() => state.value.musselSkipRounds)

  const canRoll = computed(() => !state.value.gameOver)

  function newGame(seed?: number) {
    rngSeed.value = seed ?? Math.floor(Math.random() * 0xffffffff)
    rollSeq.value = 0
    const r = createMulberry32(rngSeed.value)
    state.value = createInitialState(r)
    lastDice.value = null
    rolling.value = false
  }

  async function rollDice() {
    if (!canRoll.value || rolling.value) return
    rolling.value = true
    rollSeq.value += 1
    const r = createMulberry32(mix32(rngSeed.value, rollSeq.value))
    const dx = rollDie(r)
    const dy = rollDie(r)
    lastDice.value = { x: dx, y: dy }
    await new Promise((resolve) => setTimeout(resolve, 900))
    const { state: next } = applyMove(state.value, dx, dy, r)
    state.value = next
    rolling.value = false
  }

  function labelForPlayer(p: TileKind): string {
    return p === 'knutt' ? 'Knutt (Jäger)' : 'Herzmuschel (Beute)'
  }

  async function runSimulations(count: number) {
    if (simulating.value) return
    const n = Math.max(1, Math.min(50, Math.floor(count)))
    simulating.value = true
    simulations.value = []
    simulationProgress.value = { current: 0, total: n }

    const baseSeed = Math.floor(Math.random() * 0xffffffff)
    for (let i = 0; i < n; i++) {
      const seed = mix32(baseSeed, i + 1)
      const finalState = simulateFullGame(seed)
      simulations.value.push({
        id: i + 1,
        seed,
        snapshots: finalState.snapshots,
        rounds: finalState.round,
        finalKnutt: countTiles(finalState.board, 'knutt'),
        finalMuschel: countTiles(finalState.board, 'muschel'),
      })
      simulationProgress.value = { current: i + 1, total: n }
      // UI atmen lassen
      await new Promise((resolve) => setTimeout(resolve, 0))
    }

    simulating.value = false
  }

  function clearSimulations() {
    simulations.value = []
    simulationProgress.value = { current: 0, total: 0 }
  }

  return {
    state,
    rngSeed,
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
    simulations,
    simulating,
    simulationProgress,
    newGame,
    rollDice,
    labelForPlayer,
    runSimulations,
    clearSimulations,
  }
})
