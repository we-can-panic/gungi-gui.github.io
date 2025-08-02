import unittest
import ../components/board
import ../components/piece

suite "Board module tests":
  test "initBoard creates empty board":
    let b = initBoard()
    for x in 0..<BoardWidth:
      for y in 0..<BoardHeight:
        let cell = b.getCell(x, y)
        check cell.count == 0

  test "setCell and getCell":
    var b = initBoard()
    var cell: Cell
    let piece = newPiece(PieceType.sui, Side.black)
    cell.pushPiece(piece)
    b.setCell(1, 2, cell)
    let c2 = b.getCell(1, 2)
    check c2.count == 1
    check c2.pieces[0] != nil
    check c2.pieces[0].kind == PieceType.sui
    check c2.pieces[0].side == Side.black
  
  test "moveCell moves piece correctly":
    var b = initBoard()
    var srcCell = b.getCell(0, 0)
    let piece = newPiece(PieceType.sui, Side.black)
    srcCell.pushPiece(piece)
    b.setCell(0, 0, srcCell)
    b.moveCell((0, 0), (1, 1), MoveType.Tori)
    let dstCell = b.getCell(1, 1)
    check dstCell.count == 1
    check dstCell.pieces[0] != nil
    check dstCell.pieces[0].kind == PieceType.sui
    check dstCell.pieces[0].side == Side.black

  test "getMovableCells returns empty for empty cell":
    let b = initBoard()
    let moves = b.getMovableCells(0, 0)
    check moves.len == 0

  test "moveCell moves piece correctly":
    var b = initBoard()
    var srcCell = b.getCell(0, 0)
    let piece = newPiece(PieceType.sui, Side.black)
    srcCell.pushPiece(piece)
    b.setCell(0, 0, srcCell)
    b.moveCell((0, 0), (1, 1), MoveType.Tori)
    let dstCell = b.getCell(1, 1)
    check dstCell.count == 1
    check dstCell.pieces[0] != nil
    check dstCell.pieces[0].kind == PieceType.sui
    check dstCell.pieces[0].side == Side.black

  test "moveCell Tsuke adds piece to top of stack":
    var b = initBoard()
    var srcCell = b.getCell(0, 0)
    let piece = newPiece(PieceType.sui, Side.black)
    srcCell.pushPiece(piece)
    b.setCell(0, 0, srcCell)
    var dstCell = b.getCell(1, 1)
    dstCell.pushPiece(newPiece(PieceType.taisho, Side.white))
    b.setCell(1, 1, dstCell)
    
    b.moveCell((0, 0), (1, 1), MoveType.Tsuke)
    
    let updatedSrcCell = b.getCell(0, 0)
    let updatedDstCell = b.getCell(1, 1)
    
    check updatedSrcCell.count == 0
    check updatedDstCell.count == 2
    check updatedDstCell.pieces[1] != nil
    check updatedDstCell.pieces[1].kind == PieceType.sui
    check updatedDstCell.pieces[1].side == Side.black

  test "deletePiecesAt removes pieces of specified side":
    var b = initBoard()
    var cell = b.getCell(0, 0)
    let piece1 = newPiece(PieceType.sui, Side.black)
    let piece2 = newPiece(PieceType.taisho, Side.white)
    cell.pushPiece(piece1)
    cell.pushPiece(piece2)
    cell.deletePiecesAt(Side.black)
    b.setCell(0, 0, cell)
    check b.getCell(0, 0).count == 1
    check b.getCell(0, 0).pieces[0].kind == PieceType.taisho
    check b.getCell(0, 0).pieces[0].side == Side.white
