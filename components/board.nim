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

  grid[4][0].pushPiece(newPiece(sui, black))
  grid[3][0].pushPiece(newPiece(taisho, black))
  grid[5][0].pushPiece(newPiece(chujo, black))
  grid[1][1].pushPiece(newPiece(shinobi, black))
  grid[7][1].pushPiece(newPiece(shinobi, black))
  grid[4][1].pushPiece(newPiece(yari, black))
  grid[0][2].pushPiece(newPiece(hyou, black))
  grid[4][2].pushPiece(newPiece(hyou, black))
  grid[8][2].pushPiece(newPiece(hyou, black))
  grid[2][2].pushPiece(newPiece(toride, black))
  grid[6][2].pushPiece(newPiece(toride, black))
  grid[3][2].pushPiece(newPiece(samurai, black))
  grid[5][2].pushPiece(newPiece(samurai, black))

  grid[4][8].pushPiece(newPiece(sui, white))
  grid[3][8].pushPiece(newPiece(taisho, white))
  grid[5][8].pushPiece(newPiece(chujo, white))
  grid[1][7].pushPiece(newPiece(shinobi, white))
  grid[7][7].pushPiece(newPiece(shinobi, white))
  grid[4][7].pushPiece(newPiece(yari, white))
  grid[0][6].pushPiece(newPiece(hyou, white))
  grid[4][6].pushPiece(newPiece(hyou, white))
  grid[8][6].pushPiece(newPiece(hyou, white))
  grid[2][6].pushPiece(newPiece(toride, white))
  grid[6][6].pushPiece(newPiece(toride, white))
  grid[3][6].pushPiece(newPiece(samurai, white))
  grid[5][6].pushPiece(newPiece(samurai, white))

  return grid

# 初期置き駒を返す（必要に応じて編集）
proc placeInitialMochigoma*(): array[Side, seq[PiecePtr]] =
  var mochigoma: array[Side, seq[PiecePtr]]
  mochigoma[black] = @[
    newPiece(shosho, black),
    newPiece(shosho, black),
    newPiece(yari, black),
    newPiece(yari, black),
    newPiece(uma, black),
    newPiece(uma, black),
    newPiece(hyou, black),
  ]
  mochigoma[white] = @[
    newPiece(shosho, white),
    newPiece(shosho, white),
    newPiece(yari, white),
    newPiece(yari, white),
    newPiece(uma, white),
    newPiece(uma, white),
    newPiece(hyou, white),
  ]

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
proc getMovableCells*(b: Board, x, y: int, TSUKE_MAX: int): seq[(int, int)] =
  result = @[]
  let cell = b.grid[x][y]
  if cell.count == 0 or cell.pieces[cell.count-1] == nil:
    return
  let piece = cell.pieces[cell.count-1]
  let piecerange = getMovePattern(piece.kind, cell.count - 1, piece.side)  # stackLevelはcount-1で取得
  
  # 特殊な動き方の処理
  case piece.kind
  of taisho: # 他の駒があるまで上下左右に一直線(チェスのrookと同じ) + 斜め1マス
    for (dx, dy) in [(-1,0), (1,0), (0,-1), (0,1)]:
      var nx = x + dx
      var ny = y + dy
      while nx in 0..<BoardWidth and ny in 0..<BoardHeight:
        let targetCell = b.grid[nx][ny]
        # 何もなければ移動可能
        if targetCell.count == 0:
          result.add((nx, ny))
        # 相手の駒があれば移動可能
        elif targetCell.pieces[targetCell.count-1].side != piece.side:
          result.add((nx, ny))
          break  # それ以降は終了
        # 自分の駒があり、ツケ可能であれば移動可能
        elif targetCell.pieces[targetCell.count-1].side == piece.side and targetCell.count < TSUKE_MAX and targetCell.pieces[targetCell.count-1].kind != sui:
          result.add((nx, ny))
          break  # それ以降は終了
        nx += dx
        ny += dy
  of chujo: # 他の駒があるまで斜め一直線(チェスのbishopと同じ) + 縦横1マス
    for (dx, dy) in [(-1,-1), (-1,1), (1,-1), (1,1)]:
      var nx = x + dx
      var ny = y + dy
      while nx in 0..<BoardWidth and ny in 0..<BoardHeight:
        let targetCell = b.grid[nx][ny]
        # 何もなければ移動可能
        if targetCell.count == 0:
          result.add((nx, ny))
        # 相手の駒があれば移動可能
        elif targetCell.pieces[targetCell.count-1].side != piece.side:
          result.add((nx, ny))
          break  # それ以降は終了
        # 自分の駒があり、ツケ可能であれば移動可能
        elif targetCell.pieces[targetCell.count-1].side == piece.side and targetCell.count < TSUKE_MAX and targetCell.pieces[targetCell.count-1].kind != sui:
          result.add((nx, ny))
          break  # それ以降は終了
        nx += dx
        ny += dy
  else:
    discard

  # 通常の駒の動き
  for (dx, dy) in piecerange:
    let nx = x + dx
    let ny = y + dy
    if nx in 0..<BoardWidth and ny in 0..<BoardHeight:
      # 自分の駒がいなければ移動可
      let targetCell = b.grid[nx][ny]
      if targetCell.count == 0:
        result.add((nx, ny))
      # 自分の駒があり、ツケ可能であれば移動可能
      elif targetCell.pieces[targetCell.count-1].side == piece.side and targetCell.count < TSUKE_MAX and targetCell.pieces[targetCell.count-1].kind != sui:
        result.add((nx, ny))
      # 相手の駒があれば移動可能
      elif targetCell.pieces[targetCell.count-1].side != piece.side:
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

proc pushPiece*(b: var Board, x, y: int, piece: PiecePtr) =
  var cell = b.getCell(x, y)
  cell.pushPiece(piece)
  b.setCell(x, y, cell)