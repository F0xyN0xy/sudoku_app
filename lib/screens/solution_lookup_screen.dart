import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';
import '../services/puzzle_storage.dart';
import '../widgets/sudoku_grid_widget.dart';

class SolutionLookupScreen extends StatefulWidget {
  const SolutionLookupScreen({super.key});

  @override
  State<SolutionLookupScreen> createState() => _SolutionLookupScreenState();
}

class _SolutionLookupScreenState extends State<SolutionLookupScreen> {
  final _controller = TextEditingController();
  final _storage = PuzzleStorage();
  SudokuPuzzle? _found;
  bool _notFound = false;
  bool _loading = false;

  Future<void> _lookup() async {
    final id = _controller.text.trim();
    if (id.isEmpty) return;

    setState(() {
      _loading = true;
      _found = null;
      _notFound = false;
    });

    final result = await _storage.findById(id);

    setState(() {
      _loading = false;
      if (result != null) {
        _found = result;
      } else {
        _notFound = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution Lookup'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Puzzle ID',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'The puzzle ID is printed at the bottom of each puzzle (e.g. AB12CD34).',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. AB12CD34',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF1565C0), width: 2),
                  ),
                  prefixIcon: const Icon(Icons.tag),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              _found = null;
                              _notFound = false;
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _lookup(),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loading ? null : _lookup,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.search),
                label: const Text('Find Solution'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              if (_notFound)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade400),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No puzzle found with that ID. Make sure you\'re using the puzzle ID printed on the page.',
                        ),
                      ),
                    ],
                  ),
                ),

              if (_found != null) ...[
                _PuzzleInfoCard(puzzle: _found!),
                const SizedBox(height: 20),
                const Text(
                  'Solution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SudokuGridWidget(
                  puzzle: _found!.solution,
                  solution: _found!.solution,
                  gridSize: _found!.gridSize,
                  readOnly: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PuzzleInfoCard extends StatelessWidget {
  final SudokuPuzzle puzzle;
  const _PuzzleInfoCard({required this.puzzle});

  @override
  Widget build(BuildContext context) {
    final diffColor = puzzle.difficulty == 'easy'
        ? Colors.green
        : puzzle.difficulty == 'medium'
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puzzle found! ✓',
                  style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${puzzle.gridSize}×${puzzle.gridSize}  •  ',
                      style: TextStyle(
                          color: Colors.green.shade700, fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: diffColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        puzzle.difficulty[0].toUpperCase() +
                            puzzle.difficulty.substring(1),
                        style: TextStyle(
                            color: diffColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '  •  ${puzzle.createdAt.day}/${puzzle.createdAt.month}/${puzzle.createdAt.year}',
                      style: TextStyle(
                          color: Colors.green.shade700, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}