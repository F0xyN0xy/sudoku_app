import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';
import '../models/sudoku_puzzle.dart';
import '../services/pdf_service.dart';
import '../services/sudoku_generator.dart';
import '../services/puzzle_storage.dart';

class PrintOptionsScreen extends StatefulWidget {
  final List<SudokuPuzzle> puzzles;

  const PrintOptionsScreen({super.key, required this.puzzles});

  @override
  State<PrintOptionsScreen> createState() => _PrintOptionsScreenState();
}

class _PrintOptionsScreenState extends State<PrintOptionsScreen> {
  int _puzzlesPerPage = 1;
  bool _includeSolutions = false;
  bool _loading = false;
  final _pdfService = PdfService();
  final _generator = SudokuGenerator();
  final _storage = PuzzleStorage();
  final _uuid = const Uuid();

  bool get _needsCompanion =>
      _puzzlesPerPage == 2 && widget.puzzles.length == 1;

  Future<List<SudokuPuzzle>> _getPuzzlesForPrint() async {
    if (!_needsCompanion) return widget.puzzles;

    // Generate a second puzzle matching the same difficulty & size
    final original = widget.puzzles.first;
    final result =
        await _generator.generate(original.gridSize, original.difficulty);
    final companion = SudokuPuzzle(
      id: _uuid.v4(),
      gridSize: original.gridSize,
      difficulty: original.difficulty,
      puzzle: result.puzzle,
      solution: result.solution,
      createdAt: DateTime.now(),
    );
    await _storage.save(companion);
    return [original, companion];
  }

  Future<void> _printOrShare({required bool share}) async {
    setState(() => _loading = true);
    try {
      final puzzles = await _getPuzzlesForPrint();
      final bytes = await _pdfService.generatePuzzlesPdf(
        puzzles,
        puzzlesPerPage: _puzzlesPerPage,
        includeSolutions: _includeSolutions,
      );

      if (share) {
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'sudoku_${widget.puzzles.first.shortId}.pdf',
        );
      } else {
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: 'Sudoku Puzzles',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print / Export'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.puzzles.length} puzzle${widget.puzzles.length > 1 ? 's' : ''} selected',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),

              const Text('Puzzles per page',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              Row(
                children: [1, 2].map((n) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(n == 1 ? '1 per page' : '2 per page'),
                      selected: _puzzlesPerPage == n,
                      onSelected: (_) => setState(() => _puzzlesPerPage = n),
                      selectedColor: const Color(0xFF1565C0),
                      labelStyle: TextStyle(
                          color: _puzzlesPerPage == n
                              ? Colors.white
                              : Colors.black87),
                    ),
                  );
                }).toList(),
              ),

              // Info banner when a companion will be auto-generated
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _needsCompanion
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: const Color(0xFF90CAF9)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: Color(0xFF1565C0), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'A second ${widget.puzzles.first.difficulty} puzzle will be generated automatically to fill the page.',
                                  style: const TextStyle(
                                      color: Color(0xFF1565C0), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text('Include solution pages'),
                subtitle:
                    const Text('Adds solution pages at the end of the PDF'),
                value: _includeSolutions,
                onChanged: (v) => setState(() => _includeSolutions = v),
                activeThumbColor: const Color(0xFF1565C0),
                contentPadding: EdgeInsets.zero,
              ),

              const Spacer(),

              if (_loading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Preparing your PDF…',
                        style: TextStyle(color: Colors.black54)),
                  ],
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: () => _printOrShare(share: false),
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Print'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _printOrShare(share: true),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share / Email PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF1565C0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}