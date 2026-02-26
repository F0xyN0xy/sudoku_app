import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sudoku_puzzle.dart';

class PuzzleStorage {
  static const String _key = 'saved_puzzles';

  Future<List<SudokuPuzzle>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => SudokuPuzzle.fromJson(e)).toList();
  }

  Future<void> save(SudokuPuzzle puzzle) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    // Avoid duplicates
    all.removeWhere((p) => p.id == puzzle.id);
    all.add(puzzle);
    await prefs.setString(_key, jsonEncode(all.map((p) => p.toJson()).toList()));
  }

  Future<SudokuPuzzle?> findById(String id) async {
    final all = await loadAll();
    // Match full ID or short ID (first 8 chars)
    try {
      return all.firstWhere(
        (p) =>
            p.id.toLowerCase() == id.toLowerCase() ||
            p.shortId.toUpperCase() == id.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    all.removeWhere((p) => p.id == id);
    await prefs.setString(_key, jsonEncode(all.map((p) => p.toJson()).toList()));
  }
}