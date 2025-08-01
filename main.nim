
import karax / [vdom, karax, karaxdsl]
import components/board as boardmod  # 盤面クラス（board.nim）
import components/piece  # 駒クラス（piece.nim）
import options

type Cell = piece.Cell

var board: boardmod.Board = boardmod.initBoard()
var movableCells: seq[(int, int)] = @[]
var selectedPos: Option[(int, int)] = none((int, int))

# セル用マウスオーバー/アウト処理
proc onCellMouseOver(x, y: int, cell: Cell): proc() =
  return proc() =
    if selectedPos.isNone and cell.count > 0 and cell.pieces[cell.count-1] != nil:
      movableCells = board.getMovableCells(x, y)
      redraw()

proc onCellMouseOut(x, y: int): proc() =
  return proc() =
    if selectedPos.isNone:
      movableCells = @[]
      redraw()

# セルクリック処理
proc onCellClick(x, y: int, cell: Cell): proc() =
  return proc() =
    if selectedPos.isNone:
      # 駒選択
      if cell.count > 0 and cell.pieces[cell.count-1] != nil:
        selectedPos = some((x, y))
        movableCells = board.getMovableCells(x, y)
        redraw()
    else:
      # 移動可能範囲なら移動
      if movableCells.contains((x, y)):
        board.moveCell(selectedPos.get(), (x, y), MoveType.Tsuke)
      selectedPos = none((int, int))
      movableCells = @[]
      redraw()

proc renderBoard(b: boardmod.Board): VNode =
  buildHtml(tdiv):
    for x in 0..<boardmod.BoardWidth:
      tr(class = "board"):
        for y in 0..<boardmod.BoardHeight:
          let
            cell = board.getCell(x, y)
            piece = cell.getPiece()
            label = block:
              if piece != nil:
                $piece.kind
              else:
                ""
            sideClass = block:
              if piece != nil:
                if piece.side == black:
                  " black-side "
                else:
                  " white-side "
              else:
                ""
            movableClass = block:
              if (x, y) in movableCells:
                " movable "
              else:
                ""
          td(class = "cell " & sideClass & movableClass,
            onMouseOver = onCellMouseOver(x, y, cell),
            onMouseOut = onCellMouseOut(x, y),
            onClick = onCellClick(x, y, cell)
          ):
            text label

proc app(): VNode =
  result = buildHtml(tdiv):
    h1:
      text "軍儀 GUI"
    tdiv:
      renderBoard(board)

setRenderer(app)
