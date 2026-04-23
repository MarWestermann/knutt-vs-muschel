import 'rules.dart';
import 'rng.dart';
import 'setup.dart';
import 'types.dart';

/// Spielt ein komplettes Spiel bis `gameOver` (wie Web-Store).
GameState simulateFullGame(int seed) {
  final initRng = createMulberry32(seed);
  var s = createInitialState(initRng);
  var safety = 0;
  while (!s.gameOver && safety < 1000) {
    final stepRng = createMulberry32(mix32(seed, safety + 1));
    final dx = rollDie(stepRng);
    final dy = rollDie(stepRng);
    s = applyMove(s, dx, dy, stepRng).state;
    safety++;
  }
  return s;
}
