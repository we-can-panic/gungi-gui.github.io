# 駒の動きのテスト

import unittest
import ../components/board
import ../components/piece

suite "Piece move tests lv 1":
  test "sui moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.sui, Side.black))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 8 # 周囲8マス

  test "taisho moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.taisho, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 20 # 周囲8マス + 横6マス + 縦6マス
  
  test "chujo moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.chujo, Side.black))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 20 # 周囲8マス + 斜め12マス
  
  test "shosho moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.shosho, Side.black))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 6 # 斜め後ろを除く周囲6マス