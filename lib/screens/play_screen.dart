import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';
import '../widgets/sudoku_grid_widget.dart';
import 'print_options_screen.dart';

class PlayScreen extends StatefulWidget {
  final SudokuPuzzle puzzle;

  const PlayScreen({super.key, required this.puzzle});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  // Key so we can ask the grid widget whether it's complete
  final _gridKey = GlobalKey<SudokuGridWidgetState>();
  bool _showResults = false;

  Future<void> _printPuzzle() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PrintOptionsScreen(puzzles: [widget.puzzle])),
    );
  }

  void _onGridChanged() {
    // Trigger a rebuild so the bottom bar can update
    setState(() {});
  }

  void _revealResults() {
    setState(() => _showResults = true);
  }

  void _hideResults() {
    setState(() => _showResults = false);
  }

  bool get _isFull => _gridKey.currentState?.isFull ?? false;

  @override
  Widget build(BuildContext context) {
    final p = widget.puzzle;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${p.gridSize}×${p.gridSize} ${_capitalize(p.difficulty)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'ID: ${p.shortId}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print / Export PDF',
            onPressed: _printPuzzle,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Status banner
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showResults
                    ? _ResultsBanner(
                        key: const ValueKey('results'),
                        correctCount: _gridKey.currentState?.correctCount ?? 0,
                        totalUserFilled: _gridKey.currentState?.totalUserFilled ?? 0,
                        onHide: _hideResults,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
              if (_showResults) const SizedBox(height: 12),

              Expanded(
                child: Center(
                  child: SudokuGridWidget(
                    key: _gridKey,
                    puzzle: p.puzzle,
                    solution: p.solution,
                    gridSize: p.gridSize,
                    showResults: _showResults,
                    onChanged: _onGridChanged,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomAction(
            icon: Icons.print_outlined,
            label: 'Print',
            onTap: _printPuzzle,
          ),
          _BottomAction(
            icon: _showResults
                ? Icons.visibility_off_outlined
                : Icons.checklist_outlined,
            label: _showResults ? 'Hide' : 'Check',
            color: _isFull
                ? Colors.green.shade700
                : Colors.grey.shade400,
            onTap: _isFull
                ? (_showResults ? _hideResults : _revealResults)
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fill in all cells first!'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// Banner shown after checking
class _ResultsBanner extends StatelessWidget {
  final int correctCount;
  final int totalUserFilled;
  final VoidCallback onHide;

  const _ResultsBanner({
    super.key,
    required this.correctCount,
    required this.totalUserFilled,
    required this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    final allCorrect = correctCount == totalUserFilled;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: allCorrect ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: allCorrect ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            allCorrect ? Icons.celebration : Icons.search,
            color: allCorrect ? Colors.green.shade700 : Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              allCorrect
                  ? 'Perfect! Every cell is correct 🎉'
                  : '$correctCount / $totalUserFilled correct — wrong cells are highlighted in red',
              style: TextStyle(
                color: allCorrect
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _BottomAction(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF1565C0);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: c, fontSize: 12)),
        ],
      ),
    );
  }
}