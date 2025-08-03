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

  test "samurai moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.samurai, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 4 # 周囲4マス（斜め後ろ・真横を除く）

  test "yari moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.yari, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 5 # 周囲4マス（斜め後ろ・真横を除く） + さらに前方1マス

  test "kiba moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.kiba, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 6 # 周囲4マス（斜めを除く） + さらに前後1マス

  test "shinobi moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.shinobi, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 8 # 斜め2マス

  test "toride moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.toride, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 5 # 周囲5マス（斜め前・真後ろを除く）

  test "hyou moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.hyou, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 2 # 前後2マス

  test "oozutsu moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.oozutsu, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 4 # 横・後ろ3マス + 3マス先の前方1マス

  test "yumi moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.yumi, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 4 # 後ろ1マス + 2マス先の前方1マス + 前方桂馬2マス

  test "tsutsu moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.tsutsu, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 3 # 斜め後ろ2マス + 2マス先の前方1マス

  test "bou moves correctly":
    var b = initBoard()
    b.pushPiece(4, 4, newPiece(PieceType.bou, Side.white))
    let moves = b.getMovableCells(4, 4, 3)
    check moves.len == 3 # 斜め前2マス + 真後ろ1マス
