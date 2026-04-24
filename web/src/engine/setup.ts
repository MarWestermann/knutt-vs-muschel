import type { Board, Cell, GameState, Rng, TileKind } from './types'

export const BOARD_SIZE = 6

export function emptyBoard(): Board {
  return Array.from({ length: BOARD_SIZE }, (): Cell[] =>
    Array.from({ length: BOARD_SIZE }, (): Cell => null),
  )
}

function cloneBoard(board: Board): Board {
  return board.map((row) => [...row])
}

/** Mulberry32 – deterministischer PRNG für Tests */
export function createMulberry32(seed: number): Rng {
  return function mulberry32() {
    let t = (seed += 0x6d2b79f5)
    t = Math.imul(t ^ (t >>> 15), t | 1)
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61)
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

export function shuffleInPlace<T>(arr: T[], rng: Rng): void {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1))
    ;[arr[i], arr[j]] = [arr[j], arr[i]]
  }
}

export function pickIndex(n: number, rng: Rng): number {
  if (n <= 0) throw new Error('pickIndex: n must be positive')
  return Math.floor(rng() * n)
}

export function createInitialState(
  rng: Rng,
  options?: { starter?: TileKind },
): GameState {
  const board = emptyBoard()
  const indices = Array.from({ length: BOARD_SIZE * BOARD_SIZE }, (_, i) => i)
  shuffleInPlace(indices, rng)

  const muschelCells = indices.slice(0, 10)
  const knuttCells = indices.slice(10, 15)

  for (const i of muschelCells) {
    const r = Math.floor(i / BOARD_SIZE)
    const c = i % BOARD_SIZE
    board[r][c] = 'muschel'
  }
  for (const i of knuttCells) {
    const r = Math.floor(i / BOARD_SIZE)
    const c = i % BOARD_SIZE
    board[r][c] = 'knutt'
  }

  const starter: TileKind = options?.starter ?? 'knutt'

  return {
    board,
    turn: 0,
    round: 0,
    currentPlayer: starter,
    musselSkipRounds: 0,
    history: [],
    snapshots: [],
    gameOver: false,
  }
}

/** Tiefe Kopie des Zustands (Board wird geklont) */
export function cloneGameState(state: GameState): GameState {
  return {
    ...state,
    board: cloneBoard(state.board),
    history: [...state.history],
    snapshots: [...state.snapshots],
  }
}
