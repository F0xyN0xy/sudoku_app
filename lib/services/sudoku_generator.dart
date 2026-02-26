import 'dart:isolate';
import 'dart:math';

// ── Top-level so Isolate.run can reach it ────────────────────────────────────
Map<String, dynamic> _generateInIsolate(Map<String, dynamic> args) {
  final size = args['size'] as int;
  final difficulty = args['difficulty'] as String;
  final seed = args['seed'] as int;

  final gen = _Generator(Random(seed));
  final solution = gen.generateSolution(size);
  final puzzle = gen.createPuzzle(solution, difficulty, size);
  return {'puzzle': puzzle, 'solution': solution};
}

// ── Fast internal generator (no class state shared across isolates) ──────────
class _Generator {
  final Random rng;
  _Generator(this.rng);

  List<List<int>> generateSolution(int size) {
    final grid = List.generate(size, (_) => List.filled(size, 0));
    _fill(grid, size);
    return grid;
  }

  bool _fill(List<List<int>> grid, int size) {
    // Use bitmask sets for O(1) validity instead of .contains()
    final int box = sqrt(size).toInt();
    final rows = List.filled(size, 0);
    final cols = List.filled(size, 0);
    final boxes = List.filled(size, 0);

    // Pre-populate masks from already-filled cells
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final v = grid[r][c];
        if (v != 0) {
          final bit = 1 << v;
          rows[r] |= bit;
          cols[c] |= bit;
          boxes[(r ~/ box) * box + (c ~/ box)] |= bit;
        }
      }
    }

    return _backtrack(grid, size, box, rows, cols, boxes, 0);
  }

  bool _backtrack(
    List<List<int>> grid,
    int size,
    int box,
    List<int> rows,
    List<int> cols,
    List<int> boxes,
    int pos,
  ) {
    if (pos == size * size) return true;
    final r = pos ~/ size;
    final c = pos % size;

    if (grid[r][c] != 0) {
      return _backtrack(grid, size, box, rows, cols, boxes, pos + 1);
    }

    final bIdx = (r ~/ box) * box + (c ~/ box);
    final used = rows[r] | cols[c] | boxes[bIdx];

    // Collect valid candidates and shuffle
    final candidates = <int>[];
    for (int n = 1; n <= size; n++) {
      if (used & (1 << n) == 0) candidates.add(n);
    }
    candidates.shuffle(rng);

    for (final n in candidates) {
      final bit = 1 << n;
      grid[r][c] = n;
      rows[r] |= bit;
      cols[c] |= bit;
      boxes[bIdx] |= bit;

      if (_backtrack(grid, size, box, rows, cols, boxes, pos + 1)) return true;

      grid[r][c] = 0;
      rows[r] ^= bit;
      cols[c] ^= bit;
      boxes[bIdx] ^= bit;
    }
    return false;
  }

  List<List<int>> createPuzzle(
      List<List<int>> solution, String difficulty, int size) {
    final puzzle = solution.map((r) => List<int>.from(r)).toList();

    final cellsToRemove = switch ((size, difficulty)) {
      (4, 'easy') => 6,
      (4, 'medium') => 8,
      (4, 'hard') => 10,
      (9, 'easy') => 36,
      (9, 'medium') => 46,
      (9, 'hard') => 54,
      _ => 36,
    };

    final positions = List.generate(size * size, (i) => i)..shuffle(rng);
    int removed = 0;
    for (final pos in positions) {
      if (removed >= cellsToRemove) break;
      puzzle[pos ~/ size][pos % size] = 0;
      removed++;
    }
    return puzzle;
  }
}

// ── Public API ───────────────────────────────────────────────────────────────
class SudokuGenerator {
  /// Runs generation in a background isolate so the UI stays smooth.
  Future<({List<List<int>> puzzle, List<List<int>> solution})> generate(
      int size, String difficulty) async {
    final seed = Random().nextInt(1 << 30);
    final result = await Isolate.run(
      () => _generateInIsolate({'size': size, 'difficulty': difficulty, 'seed': seed}),
    );
    return (
      puzzle: (result['puzzle'] as List)
          .map((r) => (r as List).map((e) => e as int).toList())
          .toList(),
      solution: (result['solution'] as List)
          .map((r) => (r as List).map((e) => e as int).toList())
          .toList(),
    );
  }
}