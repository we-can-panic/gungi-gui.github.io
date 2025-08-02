import piece

const
  BoardWidth* = 9
  BoardHeight* = 9

type
  Board* = object
    grid*: array[BoardWidth, array[BoardHeight, Cell]]
    mochigoma*: array[Side, seq[PiecePtr]]  # 持ち駒（盤外の駒）

  MoveType* = enum
    Tsuke, Tori  # ツケ（置く）と取る

proc initBoard*(): Board =
  var grid: array[BoardWidth, array[BoardHeight, Cell]]
  for x in 0..<BoardWidth:
    for y in 0..<BoardHeight:
      grid[x][y] = initCell()
  var mochigoma: array[Side, seq[PiecePtr]]
  mochigoma[black] = @[]
  mochigoma[white] = @[]
  result.grid = grid
  result.mochigoma = mochigoma

# 持ち駒を追加する関数
proc addMochigoma*(b: var Board, side: Side, piece: PiecePtr) =
  b.mochigoma[side].add(piece)

# 初期駒配置を返す（必要に応じて編集）
proc placeInitialPieces*(): array[BoardWidth, array[BoardHeight, Cell] ] =
  var grid = initBoard().grid
  var blackSui: PiecePtr
  new blackSui
  blackSui[] = initPiece(sui, black)
  grid[4][0].pushPiece(blackSui)

  var whiteSui: PiecePtr
  new whiteSui
  whiteSui[] = initPiece(sui, white)
  grid[4][8].pushPiece(whiteSui)

  # 他の駒も必要に応じて配置
  var whiteTaisho: PiecePtr
  new whiteTaisho
  whiteTaisho[] = initPiece(taisho, white)
  grid[4][7].pushPiece(whiteTaisho)
  return grid

# 初期置き駒を返す（必要に応じて編集）
proc placeInitialMochigoma*(): array[Side, seq[PiecePtr]] =
  var mochigoma: array[Side, seq[PiecePtr]]
  mochigoma[black] = @[]
  mochigoma[white] = @[]
  # 例: 黒の持ち駒として黒のtaishoを1つ追加
  var blackTaisho: PiecePtr
  new blackTaisho
  blackTaisho[] = initPiece(taisho, black)
  mochigoma[black].add(blackTaisho)

  # 例: 黒の持ち駒として黒のchujoを1つ追加
  var blackChujo: PiecePtr
  new blackChujo
  blackChujo[] = initPiece(chujo, black)
  for i in 0..<10:
    mochigoma[black].add(blackChujo)

  # 例: 白の持ち駒として白のtaishoを1つ追加
  var whiteTaisho: PiecePtr
  new whiteTaisho
  whiteTaisho[] = initPiece(taisho, white)
  mochigoma[white].add(whiteTaisho)

  return mochigoma

proc getCell*(b: Board, x, y: int): Cell =
  b.grid[x][y]

proc setCell*(b: var Board, x, y: int, c: Cell) =
  b.grid[x][y] = c

proc moveCell*(b: var Board, src: (int, int), dst: (int, int), moveType: MoveType) =
  var srcCell = b.getCell(src[0], src[1])
  var dstCell = b.getCell(dst[0], dst[1])
  if moveType == Tsuke:
    # ツケ処理: dstCellに駒がいる場合は上に積む
    let movingPiece = srcCell.popPiece()
    dstCell.pushPiece(movingPiece)
  elif moveType == Tori:
    # 取る処理（必要に応じて実装）
    let movingPiece = srcCell.popPiece()
    case movingPiece.side
    of black:
        dstCell.deletePiecesAt(white)  # 白の駒を削除
    of white:
        dstCell.deletePiecesAt(black)  # 黒の駒を削除
    dstCell.pushPiece(movingPiece)
  b.setCell(src[0], src[1], srcCell)
  b.setCell(dst[0], dst[1], dstCell)

# 指定座標の駒の移動可能範囲（現状suiのみ: 上下左右1マス）
proc getMovableCells*(b: Board, x, y: int): seq[(int, int)] =
  result = @[]
  let cell = b.grid[x][y]
  if cell.count == 0 or cell.pieces[cell.count-1] == nil:
    return
  let piece = cell.pieces[cell.count-1]
  let piecerange = getMovePattern(piece.kind, cell.count - 1)  # stackLevelはcount-1で取得
  case piece.kind
  of taisho: # 他の駒があるまで上下左右に一直線(チェスのrookと同じ) + 斜め1マス
    for (dx, dy) in [(-1,0), (1,0), (0,-1), (0,1)]:
      var nx = x + dx
      var ny = y + dy
      while nx in 0..<BoardWidth and ny in 0..<BoardHeight:
        let targetCell = b.grid[nx][ny]
        if targetCell.count == 0 or targetCell.pieces[targetCell.count-1].side != piece.side:
          result.add((nx, ny))
        else:
          break  # 自分の駒があったらここで終了
        nx += dx
        ny += dy
    # 斜め1マスも追加
    for (dx, dy) in [(-1,-1), (-1,1), (1,-1), (1,1)]:
      let nx = x + dx
      let ny = y + dy
      if nx in 0..<BoardWidth and ny in 0..<BoardHeight:
        result.add((nx, ny))
  else:
    for (dx, dy) in piecerange:
      let nx = x + dx
      let ny = y + dy
      if nx in 0..<BoardWidth and ny in 0..<BoardHeight:
        # 自分の駒がいない場合のみ移動可
        let targetCell = b.grid[nx][ny]
        if targetCell.count == 0 or targetCell.pieces[targetCell.count-1] == nil or targetCell.pieces[targetCell.count-1].side != piece.side:
          result.add((nx, ny))

# 持ち駒をセットする（盤外の駒をセット）
proc placeMochigoma*(b: var Board, x, y: int, piece: PiecePtr) =
  var cell = b.getCell(x, y)
  cell.pushPiece(piece)
  b.setCell(x, y, cell)

func getPlacableCells*(b: Board, piece: PiecePtr, side: Side): seq[(int, int)] =
  result = @[]
  for x in 0..<BoardWidth:
    for y in 0..<BoardHeight:
      let cell = b.getCell(x, y)
      if cell.count == 0 or cell.pieces[cell.count-1] == nil:
        # 空のセルに持ち駒を置ける
        result.add((x, y))
      elif cell.pieces[cell.count-1].side != side:
        # 相手の駒があるセルには置けない
        continue
  return result