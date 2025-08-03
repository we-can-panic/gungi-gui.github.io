
import karax / [vdom, karax, karaxdsl]
import components/board as boardmod  # 盤面クラス（board.nim）
import components/piece  # 駒クラス（piece.nim）
import options, random

type Cell = piece.Cell


var board: boardmod.Board = boardmod.initBoard()
var movableCells: seq[(int, int)] = @[]
var placableCells: seq[(int, int)] = @[]
var selectedPos: Option[(int, int)] = none((int, int))
var selectedMochigoma: Option[(Side, int)] = none((Side, int)) # (side, index in mochigoma)
var turn: Side

# デバッグウインドウの折りたたみ状態
var debugCollapsed = false

let TSUKE_MAX = 3  # ツケの段数（最大3段まで）

proc confirm(message: cstring): bool {.importjs: "confirm(#)".}

# セル用マウスオーバー/アウト処理
proc onCellMouseOver(x, y: int, cell: Cell): proc() =
  return proc() =
    if selectedPos.isNone and cell.count > 0 and cell.pieces[cell.count-1] != nil:
      movableCells = board.getMovableCells(x, y, TSUKE_MAX)  # ツケの段数を考慮
      redraw()

proc onCellMouseOut(x, y: int): proc() =
  return proc() =
    if selectedPos.isNone:
      movableCells = @[]
      redraw()

proc turnEnd() =
  movableCells = @[]
  selectedPos = none((int, int))
  selectedMochigoma = none((Side, int))
  placableCells = @[]
  turn = if turn == black: white else: black


# セルクリック処理
proc onCellClick(x, y: int, cell: Cell): proc() =
  return proc() =
    if selectedMochigoma.isSome:
      # 持ち駒選択中→置き処理
      if placableCells.contains((x, y)):
        let (side, idx) = selectedMochigoma.get()
        let piece = board.mochigoma[side][idx]
        # 盤面に配置
        board.placeMochigoma(x, y, piece)
        # 持ち駒から削除
        board.mochigoma[side].delete(idx)
        turnEnd()
      selectedMochigoma = none((Side, int))
      placableCells = @[]
      redraw()
    elif selectedPos.isNone:
      # 駒選択
      if cell.count > 0 and cell.pieces[cell.count-1] != nil and cell.getPiece().side == turn:
        selectedPos = some((x, y))
        movableCells = board.getMovableCells(x, y, TSUKE_MAX)
        redraw()
    else:
      # 移動可能範囲なら移動
      if movableCells.contains((x, y)):
        # 移動先に相手の駒があったら、ツケるか取るか聞く
        let (sx, sy) = selectedPos.get()
        let srcPiece = board.getCell(sx, sy).getPiece()
        let dstPiece = cell.getPiece()
        if dstPiece != nil and dstPiece.side != srcPiece.side and
           cell.count < TSUKE_MAX and dstPiece.kind != sui:
          # ユーザーにツケか取るか選ばせる
          if confirm("相手の駒にツケますか？OK=ツケ, キャンセル=取る"):
            board.moveCell((sx, sy), (x, y), MoveType.Tsuke)
          else:
            board.moveCell((sx, sy), (x, y), MoveType.Tori)
        else:
          # ツケ不可能であれば取る
          board.moveCell((sx, sy), (x, y), MoveType.Tori)
        turnEnd()
      selectedPos = none((int, int))
      movableCells = @[]
      for x in 0..<BoardWidth:
        for y in 0..<BoardHeight:
          let cell = board.getCell(x, y)
          if cell.count > 0:
              echo $x & ", " & $y & ": " & $cell
      redraw()

proc onMochigomaClick(side: Side, idx: int, piece: PiecePtr): proc() =
  return proc() =
    if side == turn:
      # ツケ可能なセルを取得
      placableCells = getPlacableCells(board, piece, side)
      selectedMochigoma = some((side, idx))
      selectedPos = none((int, int))
      movableCells = @[]

proc renderMochigoma(side: Side): VNode =
  let label = if side == black: "黒" else: "白"
  let pieces = board.mochigoma[side]
  const cols = 4
  const rows = 6
  buildHtml(tdiv(class = "mochigoma-frame ")):
    tdiv(class = "mochigoma-label"):
      text label & " 持ち駒"
    table(class = "mochigoma-list"):
      for r in 0..<rows:
        tr:
          for c in 0..<cols:
            let idx = r * cols + c
            if idx < pieces.len:
              let piece = pieces[idx]
              let isSelected = selectedMochigoma.isSome and selectedMochigoma.get() == (side, idx)
              td:
                span(
                  class = "mochigoma-piece " & (if side == black: "black-side" else: "white-side") & (if isSelected: " movable" else: ""),
                  onClick = onMochigomaClick(side, idx, piece),
                ):
                  text $piece.kind
            else:
              td: text ""

proc renderBoard(b: var boardmod.Board): VNode =
  buildHtml(tdiv):
    # 盤面
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
              if (x, y) in movableCells or (x, y) in placableCells:
                " movable "
              else:
                ""
          td(class = "cell " & sideClass & movableClass,
            onMouseOver = onCellMouseOver(x, y, cell),
            onMouseOut = onCellMouseOut(x, y),
            onClick = onCellClick(x, y, cell)
          ):
            text label
    # 持ち駒表示
    tdiv(class = "mochigoma-container"):
      renderMochigoma(black)
      renderMochigoma(white)


# デバッグウインドウ
proc renderDebug(): VNode =
  buildHtml(tdiv(class = "debug-window")):
    h3(onClick = proc() =
      debugCollapsed = not debugCollapsed
      redraw()
    ,):
      text "[DEBUG]"
    if not debugCollapsed:
      tdiv:
        text "movableCells: " & $movableCells
      tdiv:
        text "selectedPos: " & $selectedPos
      tdiv:
        text "mochigoma[black]: " & $board.mochigoma[black].len & "個"
      tdiv:
        text "mochigoma[white]: " & $board.mochigoma[white].len & "個"
      # tdiv:
      #   text "placableCells: " & $placableCells
      tdiv:
        text "selectedMochigoma: " & $selectedMochigoma
      tdiv:
        text "Board cells:"
      tdiv:
        for x in 0..<boardmod.BoardWidth:
          for y in 0..<boardmod.BoardHeight:
            let cell = board.getCell(x, y)
            if cell.count > 0:
              tdiv:
                text $x & ", " & $y & ": " & $cell


proc app(): VNode =
  result = buildHtml(tdiv):
    renderDebug()
    h1:
      text "軍儀 GUI"
    tdiv:
      text "手番: " & $turn
    tdiv:
      renderBoard(board)

when isMainModule:
  # 初期配置をセット
  randomize()
  turn = Side(rand(ord(Side.high)))
  board.grid = boardmod.placeInitialPieces()
  board.mochigoma = boardmod.placeInitialMochigoma()
  setRenderer(app)
