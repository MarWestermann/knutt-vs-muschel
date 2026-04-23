/** Jäger */
export type Knutt = 'knutt'
/** Beute */
export type Muschel = 'muschel'

export type TileKind = Knutt | Muschel

export type Cell = TileKind | null

/** 6×6: board[row][col], row 0 = oben (Würfel y=1), col 0 = links (Würfel x=1) */
export type Board = Cell[][]

export interface RoundLog {
  round: number
  player: TileKind
  diceX: number
  diceY: number
  result: string
}

export interface PopulationSnapshot {
  round: number
  knutt: number
  muschel: number
}

export interface GameState {
  board: Board
  /** Abgeschlossene Würfe (1 pro Spielzug) */
  round: number
  currentPlayer: TileKind
  /** Pausenzähler für Herzmuschel-Vermehrung bei vollem Feld */
  musselSkipRounds: number
  history: RoundLog[]
  snapshots: PopulationSnapshot[]
  gameOver: boolean
  gameOverReason?: string
}

/** Zufallszahl in [0, 1) */
export type Rng = () => number
