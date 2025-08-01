
import karax / [vdom, karax, karaxdsl]
import components/board as boardmod  # 盤面クラス（board.nim）
import components/piece  # 駒クラス（piece.nim）


var board: boardmod.Board = boardmod.initBoard()
# マウスオーバー中の駒座標（なければ(-1,-1)）

var movableCells: seq[(int, int)] = @[]

# セル用マウスオーバー/アウト処理を関数で切り出し
proc onCellMouseOver(x, y: int, cell: Cell): proc() =
  return proc() =
    if cell.count > 0 and cell.pieces[cell.count-1] != nil:
      movableCells = board.getMovableCells(x, y)
      redraw()

proc onCellMouseOut(x, y: int): proc() =
  return proc() =
    movableCells = @[]
    redraw()

proc renderBoard(b: boardmod.Board): VNode =
  buildHtml(tdiv):
    for x in 0..<boardmod.BoardWidth:
      tr(class = "board"):
        for y in 0..<boardmod.BoardHeight:
          let cell = board.getCell(x, y)
          var label = ""
          var sideClass = "white-side"
          if cell.count > 0 and cell.pieces[cell.count-1] != nil:
            label = $cell.pieces[cell.count-1].kind
            if cell.pieces[cell.count-1].side == black:
              sideClass = "black-side"
          # 移動可能範囲ならクラス追加
          var movableClass = ""
          for (mx, my) in movableCells:
            if mx == x and my == y:
              movableClass = "movable"
              break
          td(class = "cell " & sideClass & (if movableClass != "": " " & movableClass else: ""),
            onMouseOver = onCellMouseOver(x, y, cell),
            onMouseOut = onCellMouseOut(x, y)
          ):
            text label

proc app(): VNode =
  result = buildHtml(tdiv):
    h1:
      text "軍儀 GUI"
    tdiv:
      renderBoard(board)

setRenderer(app)
