import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/models/sudoku_puzzle.dart';

void main() {
  final puzzleGrid = [
    [1, 0, 3, 4],
    [3, 4, 0, 2],
    [2, 1, 4, 0],
    [4, 3, 2, 1],
  ];
  final solutionGrid = [
    [1, 2, 3, 4],
    [3, 4, 1, 2],
    [2, 1, 4, 3],
    [4, 3, 2, 1],
  ];
  final progressGrid = [
    [1, 2, 3, 4],
    [3, 4, 0, 2],
    [2, 1, 4, 0],
    [4, 3, 2, 1],
  ];

  SudokuPuzzle makePuzzle({List<List<int>>? currentGrid}) => SudokuPuzzle(
        id: '12345678-test',
        gridSize: 4,
        difficulty: 'easy',
        puzzle: puzzleGrid,
        solution: solutionGrid,
        currentGrid: currentGrid,
        createdAt: DateTime.utc(2026, 1, 1),
      );

  test('serializes and restores player progress', () {
    final original = makePuzzle(currentGrid: progressGrid);
    final restored = SudokuPuzzle.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.currentGrid, progressGrid);
    expect(restored.puzzle, puzzleGrid);
    expect(restored.solution, solutionGrid);
  });

  test('loads older saved puzzles without a currentGrid field', () {
    final oldJson = makePuzzle().toJson()..remove('currentGrid');
    final restored = SudokuPuzzle.fromJson(oldJson);

    expect(restored.currentGrid, isNull);
    expect(restored.puzzle, puzzleGrid);
  });
}
