import { describe, expect, it } from 'vitest'
import { createInitialState, createMulberry32, emptyBoard } from './setup'
import { applyMove, countTiles, isBoardFull, rollDie } from './rules'
import type { Board } from './types'

function boardFromStrings(rows: string[]): Board {
  const b = emptyBoard()
  const map: Record<string, 'knutt' | 'muschel' | null> = {
    '.': null,
    K: 'knutt',
    M: 'muschel',
  }
  for (let r = 0; r < 6; r++) {
    const row = rows[r]!
    for (let c = 0; c < 6; c++) {
      b[r][c] = map[row[c]!] ?? null
    }
  }
  return b
}

describe('applyMove – Knutt', () => {
  it('frisst Herzmuschel und setzt zweites Knutt auf Nachbarfeld', () => {
    const rng = createMulberry32(42)
    const state = createInitialState(rng)
    state.board = boardFromStrings([
      '......',
      '......',
      '..M...',
      '......',
      '......',
      '......',
    ])
    state.currentPlayer = 'knutt'
    state.turn = 0
    state.round = 0
    const res = applyMove(state, 3, 3, rng)
    expect(res.state.board[2][2]).toBe('knutt')
    const kn = countTiles(res.state.board, 'knutt')
    expect(kn).toBeGreaterThanOrEqual(2)
  })

  it('entfernt Knutt auf besetztem Zielfeld (Verhungern)', () => {
    const rng = createMulberry32(1)
    const state = createInitialState(rng)
    state.board = boardFromStrings([
      '......',
      '......',
      '..K...',
      '......',
      '......',
      '......',
    ])
    state.currentPlayer = 'knutt'
    const res = applyMove(state, 3, 3, rng)
    expect(res.state.board[2][2]).toBeNull()
  })

  it('entfernt zufälligen Knutt bei leerem Ziel', () => {
    const rng = createMulberry32(99)
    const state = createInitialState(rng)
    state.board = boardFromStrings([
      'K.K...',
      '......',
      '......',
      '......',
      '......',
      '......',
    ])
    state.currentPlayer = 'knutt'
    const before = countTiles(state.board, 'knutt')
    const res = applyMove(state, 3, 3, rng)
    expect(countTiles(res.state.board, 'knutt')).toBe(before - 1)
  })
})

describe('applyMove – Herzmuschel', () => {
  it('setzt Muschel auf leeres Ziel', () => {
    const rng = createMulberry32(7)
    const state = createInitialState(rng)
    state.board = emptyBoard()
    state.board[2][2] = 'muschel'
    state.currentPlayer = 'muschel'
    const res = applyMove(state, 1, 1, rng)
    expect(res.state.board[0][0]).toBe('muschel')
  })

  it('vermehrt auf Nachbarfeld wenn Ziel schon Muschel', () => {
    const rng = createMulberry32(123)
    const state = createInitialState(rng)
    state.board = boardFromStrings([
      '......',
      '......',
      '..M...',
      '......',
      '......',
      '......',
    ])
    state.currentPlayer = 'muschel'
    const before = countTiles(state.board, 'muschel')
    const res = applyMove(state, 3, 3, rng)
    expect(countTiles(res.state.board, 'muschel')).toBe(before + 1)
  })

  it('bei Knutt: Ziel leer, neues Knutt auf Nachbarfeld', () => {
    const rng = createMulberry32(555)
    const state = createInitialState(rng)
    state.board = boardFromStrings([
      '......',
      '......',
      '..K...',
      '......',
      '......',
      '......',
    ])
    state.currentPlayer = 'muschel'
    const res = applyMove(state, 3, 3, rng)
    expect(res.state.board[2][2]).toBeNull()
    expect(countTiles(res.state.board, 'knutt')).toBe(1)
  })
})

describe('Einwanderung', () => {
  it('platziert Knutt wenn Population 0', () => {
    const rng = createMulberry32(11)
    const state = createInitialState(rng)
    state.board = emptyBoard()
    state.board[0][0] = 'muschel'
    state.currentPlayer = 'knutt'
    const res = applyMove(state, 2, 1, rng)
    expect(countTiles(res.state.board, 'knutt')).toBeGreaterThan(0)
  })
})

describe('volles Spielfeld & Snapshots', () => {
  it('setzt Pause-Zähler beim Übergang zu vollem Brett', () => {
    const rng = createMulberry32(2024)
    const state = createInitialState(rng)
    state.board = boardFromStrings([
      'MMMMMM',
      'MMMMMM',
      'MMMMMM',
      'MM.MMM',
      'MMMMMM',
      'MMMMMM',
    ])
    state.currentPlayer = 'muschel'
    state.musselSkipRounds = 0
    const res = applyMove(state, 4, 4, rng)
    expect(isBoardFull(res.state.board)).toBe(true)
    expect(res.state.musselSkipRounds).toBe(5)
  })

  it('nimmt Snapshot alle 20 Würfe (= 10 Runden)', () => {
    const rng = createMulberry32(1)
    let s = createInitialState(rng)
    for (let i = 0; i < 20; i++) {
      const dx = rollDie(rng)
      const dy = rollDie(rng)
      s = applyMove(s, dx, dy, rng).state
    }
    expect(s.snapshots.length).toBe(1)
    expect(s.snapshots[0]!.turn).toBe(20)
    expect(s.snapshots[0]!.round).toBe(10)
  })
})

describe('Runden- und Wurfzählung', () => {
  it('eine Runde besteht aus zwei Würfen (beide Spieler haben gewürfelt)', () => {
    const rng = createMulberry32(2026)
    let s = createInitialState(rng)
    expect(s.turn).toBe(0)
    expect(s.round).toBe(0)

    s = applyMove(s, rollDie(rng), rollDie(rng), rng).state
    expect(s.turn).toBe(1)
    expect(s.round).toBe(1)

    s = applyMove(s, rollDie(rng), rollDie(rng), rng).state
    expect(s.turn).toBe(2)
    expect(s.round).toBe(1)

    s = applyMove(s, rollDie(rng), rollDie(rng), rng).state
    expect(s.turn).toBe(3)
    expect(s.round).toBe(2)

    s = applyMove(s, rollDie(rng), rollDie(rng), rng).state
    expect(s.turn).toBe(4)
    expect(s.round).toBe(2)
  })

  it('beide Würfe einer Runde teilen sich dieselbe Rundennummer im Protokoll', () => {
    const rng = createMulberry32(4711)
    let s = createInitialState(rng)
    s = applyMove(s, rollDie(rng), rollDie(rng), rng).state
    s = applyMove(s, rollDie(rng), rollDie(rng), rng).state
    expect(s.history).toHaveLength(2)
    expect(s.history[0]!.round).toBe(1)
    expect(s.history[1]!.round).toBe(1)
    expect(s.history[0]!.player).not.toBe(s.history[1]!.player)
  })
})

describe('Spielende', () => {
  it('endet nach 20 Snapshots', () => {
    const rng = createMulberry32(77)
    let s = createInitialState(rng)
    let guard = 0
    while (!s.gameOver && guard++ < 1000) {
      s = applyMove(s, rollDie(rng), rollDie(rng), rng).state
    }
    expect(s.gameOver).toBe(true)
    expect(s.snapshots.length).toBe(20)
  })
})
