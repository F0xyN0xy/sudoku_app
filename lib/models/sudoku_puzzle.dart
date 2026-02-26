class SudokuPuzzle {
  final String id;
  final int gridSize; // 4 or 9
  final String difficulty; // easy, medium, hard
  final List<List<int>> puzzle; // 0 = empty
  final List<List<int>> solution;
  final DateTime createdAt;

  SudokuPuzzle({
    required this.id,
    required this.gridSize,
    required this.difficulty,
    required this.puzzle,
    required this.solution,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gridSize': gridSize,
        'difficulty': difficulty,
        'puzzle': puzzle,
        'solution': solution,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SudokuPuzzle.fromJson(Map<String, dynamic> json) => SudokuPuzzle(
        id: json['id'],
        gridSize: json['gridSize'],
        difficulty: json['difficulty'],
        puzzle: (json['puzzle'] as List)
            .map((row) => (row as List).map((e) => e as int).toList())
            .toList(),
        solution: (json['solution'] as List)
            .map((row) => (row as List).map((e) => e as int).toList())
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );

  String get shortId => id.substring(0, 8).toUpperCase();
}