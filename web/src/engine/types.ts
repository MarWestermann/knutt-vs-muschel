/** Räuber */
export type Knutt = 'knutt'
/** Beute */
export type Muschel = 'muschel'

export type TileKind = Knutt | Muschel

export type Cell = TileKind | null

/** 6×6: board[row][col], row 0 = oben (Würfel y=1), col 0 = links (Würfel x=1) */
export type Board = Cell[][]

export interface RoundLog {
  /** Laufende Wurfnummer (1 pro Spielzug) */
  turn: number
  /** Rundennummer, zu der dieser Wurf gehört (1 Runde = beide Spieler haben gewürfelt) */
  round: number
  player: TileKind
  diceX: number
  diceY: number
  result: string
}

export interface PopulationSnapshot {
  /** Wurfnummer, an der der Snapshot genommen wurde */
  turn: number
  /** Rundennummer zum Zeitpunkt des Snapshots */
  round: number
  knutt: number
  muschel: number
}

export interface GameState {
  board: Board
  /** Anzahl bereits ausgeführter Würfe (1 pro Spielzug) */
  turn: number
  /** Anzahl abgeschlossener Runden (1 Runde = beide Spieler haben einmal gewürfelt) */
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
