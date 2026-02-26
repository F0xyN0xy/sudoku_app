import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sudoku_puzzle.dart';
import '../services/puzzle_storage.dart';
import 'play_screen.dart';
import 'print_options_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<SudokuPuzzle> _puzzles = [];
  bool _loading = true;
  final Set<String> _selected = {};
  final _storage = PuzzleStorage();

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Called externally (e.g. from HomeScreen) to refresh the list
  void reload() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _storage.loadAll();
    setState(() {
      _puzzles = all.reversed.toList();
      _loading = false;
    });
  }

  Future<void> _delete(SudokuPuzzle puzzle) async {
    await _storage.delete(puzzle.id);
    _load();
  }

  void _copyId(SudokuPuzzle puzzle) {
    Clipboard.setData(ClipboardData(text: puzzle.shortId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('ID ${puzzle.shortId} copied!'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1565C0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _printSelected() {
    final selected = _puzzles.where((p) => _selected.contains(p.id)).toList();
    if (selected.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrintOptionsScreen(puzzles: selected)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selected.isEmpty
            ? 'My Puzzles'
            : '${_selected.length} selected'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          if (_selected.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Print selected',
              onPressed: _printSelected,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _selected.clear()),
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _puzzles.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _puzzles.length,
                    itemBuilder: (_, i) => _buildCard(_puzzles[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_off_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No puzzles yet',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a new puzzle from the first tab',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(SudokuPuzzle puzzle) {
    final isSelected = _selected.contains(puzzle.id);
    final diffColor = puzzle.difficulty == 'easy'
        ? Colors.green
        : puzzle.difficulty == 'medium'
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: isSelected ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? const BorderSide(color: Color(0xFF1565C0), width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (_selected.isNotEmpty) {
              setState(() {
                if (isSelected) {
                  _selected.remove(puzzle.id);
                } else {
                  _selected.add(puzzle.id);
                }
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PlayScreen(puzzle: puzzle)),
              ).then((_) => _load());
            }
          },
          onLongPress: () {
            setState(() {
              if (isSelected) {
                _selected.remove(puzzle.id);
              } else {
                _selected.add(puzzle.id);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${puzzle.gridSize}×${puzzle.gridSize}',
                    style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: diffColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _capitalize(puzzle.difficulty),
                              style: TextStyle(
                                  color: diffColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyId(puzzle),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ID: ${puzzle.shortId}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1565C0),
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.copy, size: 12, color: Color(0xFF1565C0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(puzzle.createdAt),
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFF1565C0))
                else
                  PopupMenuButton<String>(
                    icon:
                        Icon(Icons.more_vert, color: Colors.grey.shade500),
                    onSelected: (val) {
                      if (val == 'copy') {
                        _copyId(puzzle);
                      } else if (val == 'print') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PrintOptionsScreen(puzzles: [puzzle])),
                        );
                      } else if (val == 'delete') {
                        _delete(puzzle);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'copy',
                          child: Row(children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 8),
                            Text('Copy ID'),
                          ])),
                      const PopupMenuItem(
                          value: 'print',
                          child: Row(children: [
                            Icon(Icons.print_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Print / Share'),
                          ])),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ])),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}