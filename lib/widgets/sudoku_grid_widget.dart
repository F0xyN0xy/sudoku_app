import 'package:flutter/material.dart';

class SudokuGridWidget extends StatefulWidget {
  final List<List<int>> puzzle;
  final List<List<int>> solution;
  final List<List<int>>? initialGrid;
  final int gridSize;
  final bool readOnly;
  final bool showResults; // only true after user taps "Check"
  final VoidCallback? onChanged;
  final ValueChanged<List<List<int>>>? onProgressChanged;

  const SudokuGridWidget({
    super.key,
    required this.puzzle,
    required this.solution,
    required this.gridSize,
    this.initialGrid,
    this.readOnly = false,
    this.showResults = false,
    this.onChanged,
    this.onProgressChanged,
  });

  @override
  State<SudokuGridWidget> createState() => SudokuGridWidgetState();
}

class SudokuGridWidgetState extends State<SudokuGridWidget> {
  late List<List<int>> _userGrid;
  int? _selectedRow;
  int? _selectedCol;

  @override
  void initState() {
    super.initState();
    _userGrid = _copyGrid(widget.initialGrid ?? widget.puzzle);
  }

  List<List<int>> _copyGrid(List<List<int>> grid) =>
      grid.map((row) => List<int>.from(row)).toList();

  @override
  void didUpdateWidget(SudokuGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puzzle != widget.puzzle ||
        oldWidget.initialGrid != widget.initialGrid) {
      _userGrid = _copyGrid(widget.initialGrid ?? widget.puzzle);
      _selectedRow = null;
      _selectedCol = null;
    }
  }

  int get _boxSize => widget.gridSize == 4 ? 2 : 3;
  bool _isGiven(int row, int col) => widget.puzzle[row][col] != 0;

  /// True when every empty cell has been filled in.
  bool get isFull {
    for (int r = 0; r < widget.gridSize; r++) {
      for (int c = 0; c < widget.gridSize; c++) {
        if (_userGrid[r][c] == 0) return false;
      }
    }
    return true;
  }

  /// True if the completed board obeys all Sudoku constraints and preserves
  /// the original clues. This deliberately does not compare against only the
  /// generator's stored solution, so another valid solution is accepted.
  bool get isSolved {
    if (!isFull) return false;
    final size = widget.gridSize;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final value = _userGrid[r][c];
        if (value < 1 || value > size) return false;
        if (_isGiven(r, c) && value != widget.puzzle[r][c]) return false;
        for (int i = 0; i < size; i++) {
          if (i != c && _userGrid[r][i] == value) return false;
          if (i != r && _userGrid[i][c] == value) return false;
        }
        final box = _boxSize;
        final startRow = (r ~/ box) * box;
        final startCol = (c ~/ box) * box;
        for (int br = startRow; br < startRow + box; br++) {
          for (int bc = startCol; bc < startCol + box; bc++) {
            if ((br != r || bc != c) && _userGrid[br][bc] == value) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  /// How many user-filled cells are correct. A fully valid solution is
  /// accepted even if it differs from the originally stored solution.
  int get correctCount {
    if (isSolved) return totalUserFilled;
    int count = 0;
    for (int r = 0; r < widget.gridSize; r++) {
      for (int c = 0; c < widget.gridSize; c++) {
        if (!_isGiven(r, c) &&
            _userGrid[r][c] != 0 &&
            _userGrid[r][c] == widget.solution[r][c]) {
          count++;
        }
      }
    }
    return count;
  }

  /// Total number of user-filled cells (excludes givens).
  int get totalUserFilled {
    int count = 0;
    for (int r = 0; r < widget.gridSize; r++) {
      for (int c = 0; c < widget.gridSize; c++) {
        if (!_isGiven(r, c) && _userGrid[r][c] != 0) count++;
      }
    }
    return count;
  }

  void _onCellTap(int row, int col) {
    if (widget.readOnly || widget.showResults) return;
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _onNumberInput(int number) {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_isGiven(_selectedRow!, _selectedCol!)) return;
    setState(() {
      _userGrid[_selectedRow!][_selectedCol!] = number;
    });
    widget.onProgressChanged?.call(_copyGrid(_userGrid));
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildGrid(),
        if (!widget.readOnly && !widget.showResults) ...[
          const SizedBox(height: 16),
          _buildNumberPad(),
        ],
      ],
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final gridWidth = constraints.maxWidth.clamp(0.0, 380.0);
      return Container(
        width: gridWidth,
        height: gridWidth,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87, width: 2.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: List.generate(widget.gridSize, (row) {
            return Expanded(
              child: Row(
                children: List.generate(widget.gridSize, (col) {
                  return Expanded(child: _buildCell(row, col));
                }),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildCell(int row, int col) {
    final isSelected = _selectedRow == row && _selectedCol == col;
    final isRelated =
        (_selectedRow == row || _selectedCol == col) && !isSelected;
    final isSameBox = _selectedRow != null &&
        _selectedCol != null &&
        (row ~/ _boxSize == _selectedRow! ~/ _boxSize) &&
        (col ~/ _boxSize == _selectedCol! ~/ _boxSize);

    final given = _isGiven(row, col);
    final userValue = _userGrid[row][col];
    final correctValue = widget.solution[row][col];

    // If the whole board is a valid solution, don't flag values that differ
    // from the stored solution. For incomplete/invalid boards retain the
    // per-cell hint based on the stored solution.
    final isWrong = widget.showResults &&
        !isSolved &&
        !given &&
        userValue != 0 &&
        userValue != correctValue;
    final isCorrect = widget.showResults &&
        (isSolved || (!given && userValue != 0 && userValue == correctValue));

    Color bgColor = Colors.white;
    if (isWrong) {
      bgColor = Colors.red.shade50;
    } else if (isSelected && !widget.showResults) {
      bgColor = const Color(0xFF4FC3F7);
    } else if ((isSameBox || isRelated) && !widget.showResults) {
      bgColor = const Color(0xFFE3F2FD);
    }

    final isBoxBorderRight =
        col < widget.gridSize - 1 && (col + 1) % _boxSize == 0;
    final isBoxBorderBottom =
        row < widget.gridSize - 1 && (row + 1) % _boxSize == 0;

    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: col == widget.gridSize - 1
                ? BorderSide.none
                : BorderSide(
                    color: Colors.black87,
                    width: isBoxBorderRight ? 2.0 : 0.5,
                  ),
            bottom: row == widget.gridSize - 1
                ? BorderSide.none
                : BorderSide(
                    color: Colors.black87,
                    width: isBoxBorderBottom ? 2.0 : 0.5,
                  ),
          ),
        ),
        alignment: Alignment.center,
        child: userValue != 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$userValue',
                    style: TextStyle(
                      fontSize: widget.gridSize == 4 ? 20 : 17,
                      fontWeight:
                          given ? FontWeight.bold : FontWeight.normal,
                      color: given
                          ? Colors.black87
                          : isWrong
                              ? Colors.red.shade700
                              : isCorrect
                                  ? const Color(0xFF1565C0)
                                  : Colors.black87,
                    ),
                  ),
                  if (isWrong)
                    Text(
                      '$correctValue',
                      style: TextStyle(
                        fontSize: widget.gridSize == 4 ? 9 : 8,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildNumberPad() {
    final numbers = List.generate(widget.gridSize, (i) => i + 1);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ...numbers.map((n) => _NumberButton(
              number: n,
              onTap: () => _onNumberInput(n),
            )),
        _NumberButton(
          number: 0,
          label: '✕',
          onTap: () => _onNumberInput(0),
          isDelete: true,
        ),
      ],
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final String? label;
  final VoidCallback onTap;
  final bool isDelete;

  const _NumberButton({
    required this.number,
    required this.onTap,
    this.label,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDelete
              ? Colors.red.shade50
              : const Color(0xFF1565C0).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDelete
                ? Colors.red.shade200
                : const Color(0xFF1565C0).withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label ?? '$number',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDelete ? Colors.red : const Color(0xFF1565C0),
          ),
        ),
      ),
    );
  }
}
