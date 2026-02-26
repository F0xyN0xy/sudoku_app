import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/sudoku_puzzle.dart';

class PdfService {
  /// Generate a PDF with one or multiple puzzles per page
  Future<Uint8List> generatePuzzlesPdf(
    List<SudokuPuzzle> puzzles, {
    int puzzlesPerPage = 1,
    bool includeSolutions = false,
  }) async {
    final pdf = pw.Document();

    // Split puzzles into pages
    for (int i = 0; i < puzzles.length; i += puzzlesPerPage) {
      final pagePuzzles = puzzles.sublist(
          i, (i + puzzlesPerPage).clamp(0, puzzles.length));

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => _buildPage(pagePuzzles, puzzlesPerPage, includeSolutions: false),
        ),
      );
    }

    // Solution pages if requested
    if (includeSolutions) {
      for (int i = 0; i < puzzles.length; i += puzzlesPerPage) {
        final pagePuzzles = puzzles.sublist(
            i, (i + puzzlesPerPage).clamp(0, puzzles.length));

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(24),
            build: (context) => _buildPage(pagePuzzles, puzzlesPerPage, includeSolutions: true),
          ),
        );
      }
    }

    return pdf.save();
  }

  pw.Widget _buildPage(List<SudokuPuzzle> puzzles, int puzzlesPerPage,
      {required bool includeSolutions}) {
    if (puzzles.length == 1) {
      return pw.Center(
        child: _buildPuzzleBlock(puzzles[0], includeSolutions: includeSolutions),
      );
    }

    // 2 per page: vertical split
    return pw.Column(
      children: puzzles
          .map((p) => pw.Expanded(
                child: pw.Center(
                  child: _buildPuzzleBlock(p, includeSolutions: includeSolutions, compact: true),
                ),
              ))
          .toList(),
    );
  }

  pw.Widget _buildPuzzleBlock(SudokuPuzzle puzzle,
      {bool includeSolutions = false, bool compact = false}) {
    final title = includeSolutions ? 'SOLUTION' : puzzle.difficulty.toUpperCase();
    final grid = includeSolutions ? puzzle.solution : puzzle.puzzle;
    final cellSize = puzzle.gridSize == 4
        ? (compact ? 40.0 : 60.0)
        : (compact ? 28.0 : 40.0);

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          'SUDOKU — $title',
          style: pw.TextStyle(
            fontSize: compact ? 14 : 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'ID: ${puzzle.shortId}  •  ${puzzle.gridSize}×${puzzle.gridSize}  •  ${puzzle.createdAt.day}/${puzzle.createdAt.month}/${puzzle.createdAt.year}',
          style: pw.TextStyle(fontSize: compact ? 8 : 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        _buildGrid(grid, puzzle.gridSize, cellSize, puzzle.puzzle),
        pw.SizedBox(height: 6),
        pw.Text(
          includeSolutions
              ? 'To look up solutions: open the app → Solutions → enter ID: ${puzzle.shortId}'
              : 'Solutions: open Sudoku app → Solutions tab → enter puzzle ID',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildGrid(List<List<int>> grid, int size, double cellSize,
      List<List<int>> originalPuzzle) {
    int boxSize = size == 4 ? 2 : 3;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2.5),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: List.generate(size, (row) {
          return pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: List.generate(size, (col) {
              final value = grid[row][col];
              final isGiven = originalPuzzle[row][col] != 0;
              final isBoxBorderRight =
                  col < size - 1 && (col + 1) % boxSize == 0;
              final isBoxBorderBottom =
                  row < size - 1 && (row + 1) % boxSize == 0;

              return pw.Container(
                width: cellSize,
                height: cellSize,
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    right: isBoxBorderRight
                        ? const pw.BorderSide(width: 2)
                        : const pw.BorderSide(width: 0.5),
                    bottom: isBoxBorderBottom
                        ? const pw.BorderSide(width: 2)
                        : const pw.BorderSide(width: 0.5),
                    left: col == 0
                        ? pw.BorderSide.none
                        : pw.BorderSide.none,
                    top: row == 0 ? pw.BorderSide.none : pw.BorderSide.none,
                  ),
                ),
                alignment: pw.Alignment.center,
                child: value != 0
                    ? pw.Text(
                        '$value',
                        style: pw.TextStyle(
                          fontSize: cellSize * 0.45,
                          fontWeight: isGiven
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal,
                          color: isGiven ? PdfColors.black : PdfColors.blue800,
                        ),
                      )
                    : pw.SizedBox(),
              );
            }),
          );
        }),
      ),
    );
  }
}