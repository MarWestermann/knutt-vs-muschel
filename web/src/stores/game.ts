import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { applyMove, countTiles, rollDie } from '@/engine/rules'
import { createInitialState, createMulberry32 } from '@/engine/setup'
import type { GameState, TileKind } from '@/engine/types'

export const useGameStore = defineStore('game', () => {
  const rngSeed = ref(Math.floor(Math.random() * 0xffffffff))
  /** Fortlaufender Zähler für deterministische Würfel-Streams pro Zug */
  const rollSeq = ref(0)

  const state = ref<GameState>(createInitialState(createMulberry32(rngSeed.value)))

  const lastDice = ref<{ x: number; y: number } | null>(null)
  const rolling = ref(false)

  function mix32(a: number, b: number): number {
    return (Math.imul(a ^ b, 0x9e3779b9) >>> 0) ^ a
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
    await new Promise((resolve) => setTimeout(resolve, 450))
    const { state: next } = applyMove(state.value, dx, dy, r)
    state.value = next
    rolling.value = false
  }

  function labelForPlayer(p: TileKind): string {
    return p === 'knutt' ? 'Knutt (Jäger)' : 'Herzmuschel (Beute)'
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
    newGame,
    rollDice,
    labelForPlayer,
  }
})
