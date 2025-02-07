import 'package:flutter/material.dart';

class MoveData {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final bool isCapture;
  final int? capRow;
  final int? capCol;

  MoveData({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    this.isCapture = false,
    this.capRow,
    this.capCol,
  });
}

class CheckersBoard extends StatefulWidget {
  final String color;
  final bool canMove;
  final List<Map<String, dynamic>> moves;
  final Function(String) onMove;

  const CheckersBoard({
    super.key,
    required this.color,
    required this.canMove,
    required this.moves,
    required this.onMove,
  });

  @override
  State<CheckersBoard> createState() => _CheckersBoardState();
}

class _CheckersBoardState extends State<CheckersBoard> {
  late List<List<String>> _localBoard;

  int? _selRow;
  int? _selCol;

  bool _multiCapture = false;

  List<List<bool>> _available =
      List.generate(8, (_) => List.generate(8, (_) => false));

  @override
  void initState() {
    super.initState();
    _buildLocalBoardFromServer();
  }

  @override
  void didUpdateWidget(covariant CheckersBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moves != widget.moves) {
      final wasSelected = (_selRow != null && _selCol != null);
      final oldRow = _selRow;
      final oldCol = _selCol;

      _buildLocalBoardFromServer();

      if (wasSelected && oldRow != null && oldCol != null) {
        final piece = _localBoard[oldRow][oldCol];
        if (piece.isNotEmpty && piece.startsWith(widget.color)) {
          _selRow = oldRow;
          _selCol = oldCol;
          _calcMovesForSelected();
        } else {
          _clearSelection();
        }
      }
    }
  }

  void _buildLocalBoardFromServer() {
    _localBoard = List.generate(8, (_) => List.generate(8, (_) => ''));

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 8; c++) {
        if ((r + c) % 2 == 0) {
          _localBoard[r][c] = 'B';
        }
      }
    }
    for (int r = 5; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if ((r + c) % 2 == 0) {
          _localBoard[r][c] = 'R';
        }
      }
    }

    for (final m in widget.moves) {
      final fromArr = (m['from'] as String).split(',');
      final toArr = (m['to'] as String).split(',');
      if (fromArr.length < 2 || toArr.length < 2) continue;

      final fr = int.tryParse(fromArr[0]) ?? 0;
      final fc = int.tryParse(fromArr[1]) ?? 0;
      final tr = int.tryParse(toArr[0]) ?? 0;
      final tc = int.tryParse(toArr[1]) ?? 0;

      if ((fr + tr) % 2 == 0 && (fc + tc) % 2 == 0) {
        int jumpedOverR = int.parse("${(fr + tr) / 2}");
        int jumpedOverC = int.parse("${(fc + tc) / 2}");

        if (_localBoard[jumpedOverR][jumpedOverC].isNotEmpty) {
          _localBoard[jumpedOverR][jumpedOverC] = '';
        }
      }

      final piece = _localBoard[fr][fc];
      _localBoard[fr][fc] = '';
      _localBoard[tr][tc] = piece;

      if (piece == 'R' && tr == 0) {
        _localBoard[tr][tc] = 'RK';
      } else if (piece == 'B' && tr == 7) {
        _localBoard[tr][tc] = 'BK';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        itemCount: 64,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (ctx, index) {
          final r = index ~/ 8;
          final c = index % 8;
          final piece = _localBoard[r][c];

          final isDark = ((r + c) % 2 == 0);
          final cellColor = _available[r][c]
              ? Colors.blueAccent
              : (isDark ? Colors.brown[300]! : Colors.brown[100]!);

          final isSelected = (_selRow == r && _selCol == c);

          return GestureDetector(
            onTap: () => _onTapCell(r, c),
            child: Container(
              decoration: BoxDecoration(
                color: cellColor,
                border: isSelected
                    ? Border.all(color: Colors.yellow, width: 2)
                    : null,
              ),
              child: Center(child: _buildPieceWidget(piece)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieceWidget(String piece) {
    if (piece.isEmpty) return SizedBox.shrink();

    final isRed = piece.startsWith('R');
    final color = isRed ? Colors.red : Colors.black;
    final king = (piece == 'RK' || piece == 'BK');

    return CircleAvatar(
      radius: 16,
      backgroundColor: color,
      child:
          king ? const Icon(Icons.star, color: Colors.white, size: 18) : null,
    );
  }

  void _onTapCell(int row, int col) {
    if (!widget.canMove) return;
    final tappedPiece = _localBoard[row][col];

    if (_selRow == null && _selCol == null) {
      if (tappedPiece.isNotEmpty && tappedPiece.startsWith(widget.color)) {
        setState(() {
          _selRow = row;
          _selCol = col;
          _multiCapture = false;
        });
        _calcMovesForSelected();
      }
      return;
    }

    if (_available[row][col]) {
      _doLocalMove(_selRow!, _selCol!, row, col);
    } else {
      if (tappedPiece.isNotEmpty && tappedPiece.startsWith(widget.color)) {
        setState(() {
          _selRow = row;
          _selCol = col;
          _multiCapture = false;
        });
        _calcMovesForSelected();
      } else {
        setState(() => _clearSelection());
      }
    }
  }

  void _doLocalMove(int fr, int fc, int tr, int tc) {
    final piece = _localBoard[fr][fc];
    final theMove = _findLocalMove(fr, fc, tr, tc);
    int? cr, cc;
    final isCapture = theMove?.isCapture ?? false;
    if (isCapture) {
      cr = theMove!.capRow;
      cc = theMove.capCol;
    }

    if (cr != null && cc != null) {
      _localBoard[cr][cc] = '';
    }

    _localBoard[fr][fc] = '';
    _localBoard[tr][tc] = piece;

    if (piece == 'R' && tr == 0) {
      _localBoard[tr][tc] = 'RK';
    } else if (piece == 'B' && tr == 7) {
      _localBoard[tr][tc] = 'BK';
    }

    final moveStr = 'from=($fr,$fc)|to=($tr,$tc)';
    widget.onMove(moveStr);

    setState(() {
      _clearSelection();
    });
  }

  void _clearSelection() {
    _selRow = null;
    _selCol = null;
    _multiCapture = false;
    _available = List.generate(8, (_) => List.generate(8, (_) => false));
  }

  void _calcMovesForSelected() {
    _available = List.generate(8, (_) => List.generate(8, (_) => false));
    if (_selRow == null || _selCol == null) return;
    final sr = _selRow!;
    final sc = _selCol!;
    final piece = _localBoard[sr][sc];
    if (piece.isEmpty || !piece.startsWith(widget.color)) return;

    final all = _getAllMovesForColor(widget.color);
    final forcedCapture = all.any((m) => m.isCapture);

    final pieceMoves = _getMovesForPiece(sr, sc);
    final filtered = forcedCapture
        ? pieceMoves.where((m) => m.isCapture).toList()
        : pieceMoves;

    setState(() {
      for (final mv in filtered) {
        _available[mv.toRow][mv.toCol] = true;
      }
    });
  }

  List<MoveData> _getAllMovesForColor(String color) {
    final result = <MoveData>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = _localBoard[r][c];
        if (p.isNotEmpty && p.startsWith(color)) {
          result.addAll(_getMovesForPiece(r, c));
        }
      }
    }
    return result;
  }

  List<MoveData> _getMovesForPiece(int row, int col) {
    final piece = _localBoard[row][col];
    if (piece.isEmpty) return [];
    if (!piece.startsWith(widget.color)) return [];

    final isKing = (piece == 'RK' || piece == 'BK');
    final directions = isKing
        ? <List<int>>[
            [-1, -1],
            [-1, 1],
            [1, -1],
            [1, 1],
          ]
        : (piece.startsWith('R')
            ? <List<int>>[
                [-1, -1],
                [-1, 1]
              ]
            : <List<int>>[
                [1, -1],
                [1, 1]
              ]);

    final result = <MoveData>[];

    for (var d in directions) {
      final nr = row + d[0];
      final nc = col + d[1];
      if (_onBoard(nr, nc) && _localBoard[nr][nc].isEmpty) {
        result.add(MoveData(
          fromRow: row,
          fromCol: col,
          toRow: nr,
          toCol: nc,
        ));
      }
    }
    for (var d in directions) {
      final cr = row + d[0];
      final cc = col + d[1];
      final lr = row + 2 * d[0];
      final lc = col + 2 * d[1];
      if (!_onBoard(cr, cc) || !_onBoard(lr, lc)) continue;

      final adjPiece = _localBoard[cr][cc];
      final isOpp = (piece.startsWith('R') && adjPiece.startsWith('B')) ||
          (piece.startsWith('B') && adjPiece.startsWith('R'));
      if (isOpp && _localBoard[lr][lc].isEmpty) {
        result.add(MoveData(
          fromRow: row,
          fromCol: col,
          toRow: lr,
          toCol: lc,
          isCapture: true,
          capRow: cr,
          capCol: cc,
        ));
      }
    }
    return result;
  }

  MoveData? _findLocalMove(int fr, int fc, int tr, int tc) {
    final moves = _getMovesForPiece(fr, fc);
    return moves.firstWhere(
      (m) =>
          m.fromRow == fr && m.fromCol == fc && m.toRow == tr && m.toCol == tc,
      orElse: () => MoveData(fromRow: fr, fromCol: fc, toRow: tr, toCol: tc),
    );
  }

  bool _onBoard(int r, int c) => (r >= 0 && r < 8 && c >= 0 && c < 8);
}
