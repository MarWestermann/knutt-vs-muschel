/// JavaScript `Math.imul` – 32-Bit signiert, wie in der Web-Engine.
@pragma('vm:prefer-inline')
int imul32(int a, int b) {
  final aLo = a & 0xffff;
  final aHi = a >> 16;
  final bLo = b & 0xffff;
  final bHi = b >> 16;
  return (aLo * bLo + (((aLo * bHi + aHi * bLo) << 16) & 0xffffffff)) & 0xffffffff;
}

/// Zufallszahl in [0, 1) – bitgleich zu [`createMulberry32`] in Web `setup.ts`.
typedef Rng = double Function();

/// Mulberry32 – deterministischer PRNG (gleiche Formel wie TypeScript).
Rng createMulberry32(int seed) {
  var s = seed & 0xffffffff;
  return () {
    int t = (s + 0x6d2b79f5) & 0xffffffff;
    s = t;
    t = imul32(t ^ (t >>> 15), t | 1) & 0xffffffff;
    t = (t ^ (t + imul32(t ^ (t >>> 7), t | 61))) & 0xffffffff;
    return ((t ^ (t >>> 14)) & 0xffffffff) / 4294967296.0;
  };
}

/// Wie `mix32` im Web-Store (`game.ts`).
int mix32(int a, int b) => (imul32(a ^ b, 0x9e3779b9) ^ a) & 0xffffffff;
