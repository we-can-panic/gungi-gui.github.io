# 駒の動きのテスト

import unittest
import ../components/board
import ../components/piece

suite "Piece move tests":
  test "sui moves correctly":
    var b = initBoard()
    b.pushPiece(0, 0, newPiece(PieceType.sui, Side.black))
    let moves = b.getMovableCells(0, 0, 3)
    check moves.len == 3 # (1, 0), (0, 1), (1, 1)

  test "taisho moves correctly":
    var b = initBoard()
    b.pushPiece(1, 1, newPiece(PieceType.taisho, Side.white))
    let moves = b.getMovableCells(1, 1, 3)
    check moves.len == 20 # 周囲8マス + 横6マス + 縦6マス
  
  test "chujo moves correctly":
    var b = initBoard()
    b.pushPiece(1, 1, newPiece(PieceType.chujo, Side.black))
    let moves = b.getMovableCells(1, 1, 3)
    check moves.len == 14 # 周囲8マス + 斜め6マス
  
  test "shosho moves correctly":
    var b = initBoard()
    b.pushPiece(1, 1, newPiece(PieceType.shosho, Side.black))
    let moves = b.getMovableCells(1, 1, 3)
    check moves.len == 6 # 斜め後ろを除く周囲6マス