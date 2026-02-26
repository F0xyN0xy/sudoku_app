import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/sudoku_puzzle.dart';
import '../services/sudoku_generator.dart';
import '../services/puzzle_storage.dart';
import 'play_screen.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  String _difficulty = 'medium';
  int _gridSize = 9;
  bool _generating = false;

  final _generator = SudokuGenerator();
  final _storage = PuzzleStorage();
  final _uuid = const Uuid();

  Future<void> _generate() async {
    setState(() => _generating = true);

    final result = await _generator.generate(_gridSize, _difficulty);
    final puzzle = SudokuPuzzle(
      id: _uuid.v4(),
      gridSize: _gridSize,
      difficulty: _difficulty,
      puzzle: result.puzzle,
      solution: result.solution,
      createdAt: DateTime.now(),
    );

    await _storage.save(puzzle);

    if (!mounted) return;
    setState(() => _generating = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayScreen(puzzle: puzzle)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 Sudoku App'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'New Puzzle',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Grid size
              const _SectionLabel(label: 'Grid Size'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ChoiceChip(
                    label: '4×4 Mini',
                    selected: _gridSize == 4,
                    onTap: () => setState(() => _gridSize = 4),
                  ),
                  const SizedBox(width: 12),
                  _ChoiceChip(
                    label: '9×9 Classic',
                    selected: _gridSize == 9,
                    onTap: () => setState(() => _gridSize = 9),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Difficulty
              const _SectionLabel(label: 'Difficulty'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ChoiceChip(
                    label: 'Easy',
                    color: Colors.green,
                    selected: _difficulty == 'easy',
                    onTap: () => setState(() => _difficulty = 'easy'),
                  ),
                  const SizedBox(width: 8),
                  _ChoiceChip(
                    label: 'Medium',
                    color: Colors.orange,
                    selected: _difficulty == 'medium',
                    onTap: () => setState(() => _difficulty = 'medium'),
                  ),
                  const SizedBox(width: 8),
                  _ChoiceChip(
                    label: 'Hard',
                    color: Colors.red,
                    selected: _difficulty == 'hard',
                    onTap: () => setState(() => _difficulty = 'hard'),
                  ),
                ],
              ),

              const Spacer(),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1565C0)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Each puzzle gets a unique ID. You can print it out or find the solution later using the ID.',
                        style: TextStyle(
                            color: Colors.blue.shade800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _generating ? null : _generate,
                icon: _generating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.casino_outlined),
                label: Text(_generating ? 'Generating...' : 'Generate Puzzle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? const Color(0xFF1565C0);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? activeColor : Colors.grey.shade300, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}