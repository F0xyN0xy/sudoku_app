import 'package:flutter/material.dart';

class SudokuGridWidget extends StatefulWidget {
  final List<List<int>> puzzle;
  final List<List<int>> solution;
  final int gridSize;
  final bool readOnly;
  final bool showResults; // only true after user taps "Check"
  final VoidCallback? onChanged;

  const SudokuGridWidget({
    super.key,
    required this.puzzle,
    required this.solution,
    required this.gridSize,
    this.readOnly = false,
    this.showResults = false,
    this.onChanged,
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
    _userGrid = widget.puzzle.map((row) => List<int>.from(row)).toList();
  }

  @override
  void didUpdateWidget(SudokuGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puzzle != widget.puzzle) {
      _userGrid = widget.puzzle.map((row) => List<int>.from(row)).toList();
      _selectedRow = null;
      _selectedCol = null;
    }
  }

  int get _boxSize => widget.gridSize == 4 ? 2 : 3;
  bool _isGiven(int row, int col) => widget.puzzle[row][col] != 0;

  /// True when every empty cell has been filled in
  bool get isFull {
    for (int r = 0; r < widget.gridSize; r++) {
      for (int c = 0; c < widget.gridSize; c++) {
        if (!_isGiven(r, c) && _userGrid[r][c] == 0) return false;
      }
    }
    return true;
  }

  /// How many user-filled cells are correct
  int get correctCount {
    int count = 0;
    for (int r = 0; r < widget.gridSize; r++) {
      for (int c = 0; c < widget.gridSize; c++) {
        if (!_isGiven(r, c) && _userGrid[r][c] != 0) {
          if (_userGrid[r][c] == widget.solution[r][c]) count++;
        }
      }
    }
    return count;
  }

  /// Total number of user-filled cells (excludes givens)
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

    // Only colour cells when results are revealed
    final isWrong = widget.showResults && !given && userValue != 0 && userValue != correctValue;
    final isCorrect = widget.showResults && !given && userValue != 0 && userValue == correctValue;

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
                  // Show correct number underneath wrong ones
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