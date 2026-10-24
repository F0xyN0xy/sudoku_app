class SudokuPuzzle {
  final String id;
  final int gridSize; // 4 or 9
  final String difficulty; // easy, medium, hard
  final List<List<int>> puzzle; // 0 = empty
  final List<List<int>> solution;

  /// The player's current board. Null means the puzzle has not been started.
  final List<List<int>>? currentGrid;
  final DateTime createdAt;

  SudokuPuzzle({
    required this.id,
    required this.gridSize,
    required this.difficulty,
    required this.puzzle,
    required this.solution,
    this.currentGrid,
    required this.createdAt,
  });

  SudokuPuzzle copyWith({List<List<int>>? currentGrid}) => SudokuPuzzle(
        id: id,
        gridSize: gridSize,
        difficulty: difficulty,
        puzzle: puzzle.map((row) => List<int>.from(row)).toList(),
        solution: solution.map((row) => List<int>.from(row)).toList(),
        currentGrid: currentGrid?.map((row) => List<int>.from(row)).toList(),
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'gridSize': gridSize,
        'difficulty': difficulty,
        'puzzle': puzzle,
        'solution': solution,
        if (currentGrid != null) 'currentGrid': currentGrid,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SudokuPuzzle.fromJson(Map<String, dynamic> json) => SudokuPuzzle(
        id: json['id'] as String,
        gridSize: json['gridSize'] as int,
        difficulty: json['difficulty'] as String,
        puzzle: (json['puzzle'] as List)
            .map((row) => (row as List).map((e) => e as int).toList())
            .toList(),
        solution: (json['solution'] as List)
            .map((row) => (row as List).map((e) => e as int).toList())
            .toList(),
        currentGrid: json['currentGrid'] == null
            ? null
            : (json['currentGrid'] as List)
                .map((row) => (row as List).map((e) => e as int).toList())
                .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String get shortId =>
      id.substring(0, id.length < 8 ? id.length : 8).toUpperCase();
}
