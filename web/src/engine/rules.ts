import { BOARD_SIZE, cloneGameState, pickIndex } from './setup'
import type { Board, GameState, Rng, TileKind } from './types'

const MAX_ROUNDS = 200
const SNAPSHOT_INTERVAL = 10
const MAX_SNAPSHOTS = 20

export function countTiles(board: Board, kind: TileKind): number {
  let n = 0
  for (let r = 0; r < BOARD_SIZE; r++) {
    for (let c = 0; c < BOARD_SIZE; c++) {
      if (board[r][c] === kind) n++
    }
  }
  return n
}

export function isBoardFull(board: Board): boolean {
  for (let r = 0; r < BOARD_SIZE; r++) {
    for (let c = 0; c < BOARD_SIZE; c++) {
      if (board[r][c] === null) return false
    }
  }
  return true
}

function neighbors8(r: number, c: number): [number, number][] {
  const out: [number, number][] = []
  for (let dr = -1; dr <= 1; dr++) {
    for (let dc = -1; dc <= 1; dc++) {
      if (dr === 0 && dc === 0) continue
      const nr = r + dr
      const nc = c + dc
      if (nr >= 0 && nr < BOARD_SIZE && nc >= 0 && nc < BOARD_SIZE) {
        out.push([nr, nc])
      }
    }
  }
  return out
}

function allCellsWith(board: Board, kind: TileKind): [number, number][] {
  const out: [number, number][] = []
  for (let r = 0; r < BOARD_SIZE; r++) {
    for (let c = 0; c < BOARD_SIZE; c++) {
      if (board[r][c] === kind) out.push([r, c])
    }
  }
  return out
}

function allEmptyCells(board: Board): [number, number][] {
  const out: [number, number][] = []
  for (let r = 0; r < BOARD_SIZE; r++) {
    for (let c = 0; c < BOARD_SIZE; c++) {
      if (board[r][c] === null) out.push([r, c])
    }
  }
  return out
}

function pickRandomCell(cells: [number, number][], rng: Rng): [number, number] {
  return cells[pickIndex(cells.length, rng)]!
}

function freeNeighbors(board: Board, r: number, c: number): [number, number][] {
  return neighbors8(r, c).filter(([nr, nc]) => board[nr][nc] === null)
}

function applyImmigration(board: Board, rng: Rng): string[] {
  const msgs: string[] = []
  const empty = () => allEmptyCells(board)
  if (countTiles(board, 'knutt') === 0) {
    const e = empty()
    if (e.length > 0) {
      const [r, c] = pickRandomCell(e, rng)
      board[r][c] = 'knutt'
      msgs.push('Einwanderung: Ein Knutt erscheint auf dem Spielfeld.')
    }
  }
  if (countTiles(board, 'muschel') === 0) {
    const e = empty()
    if (e.length > 0) {
      const [r, c] = pickRandomCell(e, rng)
      board[r][c] = 'muschel'
      msgs.push('Einwanderung: Eine Herzmuschel erscheint auf dem Spielfeld.')
    }
  }
  return msgs
}

export interface ApplyMoveResult {
  state: GameState
  /** Kurzbeschreibung für Log */
  messages: string[]
}

/**
 * Führt einen Spielzug aus: aktueller Spieler würfelt (diceX = Spalte 1–6, diceY = Zeile 1–6).
 */
export function applyMove(
  state: GameState,
  diceX: number,
  diceY: number,
  rng: Rng,
): ApplyMoveResult {
  if (state.gameOver) {
    return { state: cloneGameState(state), messages: ['Spiel ist bereits beendet.'] }
  }

  const s = cloneGameState(state)
  const board = s.board
  const fullBefore = isBoardFull(board)
  const player = s.currentPlayer
  const row = diceY - 1
  const col = diceX - 1
  const cell = board[row][col]

  const messages: string[] = []
  const coord = `Feld (${diceX}|${diceY})`

  if (player === 'knutt') {
    if (cell === 'muschel') {
      board[row][col] = 'knutt'
      const free = freeNeighbors(board, row, col)
      if (free.length > 0) {
        const [nr, nc] = pickRandomCell(free, rng)
        board[nr][nc] = 'knutt'
        messages.push(`${coord}: Knutt frisst Herzmuschel und vermehrt sich (zweites Knutt auf Nachbarfeld).`)
      } else {
        messages.push(`${coord}: Knutt frisst Herzmuschel (kein freies Nachbarfeld für Vermehrung).`)
      }
    } else if (cell === 'knutt') {
      board[row][col] = null
      messages.push(`${coord}: Knutt verhungert (Ziel war besetzt).`)
    } else {
      const knutts = allCellsWith(board, 'knutt')
      if (knutts.length === 0) {
        messages.push(`${coord}: Leeres Ziel – keine Knutts zum Entfernen.`)
      } else {
        const [kr, kc] = pickRandomCell(knutts, rng)
        board[kr][kc] = null
        messages.push(`${coord}: Knutt verhungert – ein Knutt wird vom Spielfeld entfernt.`)
      }
    }
  } else {
    // Herzmuschel
    if (cell === 'knutt') {
      board[row][col] = null
      const free = freeNeighbors(board, row, col)
      if (free.length > 0) {
        const [nr, nc] = pickRandomCell(free, rng)
        board[nr][nc] = 'knutt'
        messages.push(`${coord}: Herzmuschel wird gefressen – Knutt auf Nachbarfeld.`)
      } else {
        board[row][col] = 'knutt'
        messages.push(`${coord}: Herzmuschel wird gefressen – kein Nachbarfeld frei, Knutt bleibt am Ziel.`)
      }
    } else {
      const full = isBoardFull(board)
      // Vermehrung: leeres Ziel oder Herzmuschel auf Herzmuschel
      if (full && s.musselSkipRounds > 0) {
        s.musselSkipRounds -= 1
        messages.push(
          `${coord}: Herzmuschel-Vermehrung ausgesetzt (volles Spielfeld, noch ${s.musselSkipRounds} Pause-Züge).`,
        )
      } else if (cell === null) {
        board[row][col] = 'muschel'
        messages.push(`${coord}: Herzmuschel vermehrt sich (neues Plättchen auf leeres Ziel).`)
      } else {
        const free = freeNeighbors(board, row, col)
        if (free.length > 0) {
          const [nr, nc] = pickRandomCell(free, rng)
          board[nr][nc] = 'muschel'
          messages.push(`${coord}: Herzmuschel vermehrt sich (Nachbarfeld).`)
        } else {
          messages.push(`${coord}: Herzmuschel kann sich nicht vermehren (kein freies Nachbarfeld).`)
        }
      }
    }
  }

  messages.push(...applyImmigration(board, rng))

  const fullAfter = isBoardFull(board)
  if (!fullAfter) {
    s.musselSkipRounds = 0
  } else if (!fullBefore && fullAfter) {
    s.musselSkipRounds = 5
  }

  s.round += 1
  const summary = messages.join(' ')

  s.history.push({
    round: s.round,
    player,
    diceX,
    diceY,
    result: summary,
  })

  if (s.round % SNAPSHOT_INTERVAL === 0 && s.snapshots.length < MAX_SNAPSHOTS) {
    s.snapshots.push({
      round: s.round,
      knutt: countTiles(board, 'knutt'),
      muschel: countTiles(board, 'muschel'),
    })
  }

  s.currentPlayer = player === 'knutt' ? 'muschel' : 'knutt'

  if (s.round >= MAX_ROUNDS || s.snapshots.length >= MAX_SNAPSHOTS) {
    s.gameOver = true
    s.gameOverReason =
      s.snapshots.length >= MAX_SNAPSHOTS
        ? '20 Protokollpunkte erreicht (wie im Original).'
        : '200 Würfe erreicht.'
  }

  return { state: s, messages }
}

/** Würfelwurf 1–6 */
export function rollDie(rng: Rng): number {
  return pickIndex(6, rng) + 1
}
