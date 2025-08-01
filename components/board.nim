import piece

const
  BoardWidth* = 9
  BoardHeight* = 9

type
  Board* = object
    grid*: array[BoardWidth, array[BoardHeight, Cell]]


# 初期駒配置を返す（必要に応じて編集）
proc placeInitialPieces(): array[BoardWidth, array[BoardHeight, Cell] ] =
  var grid: array[BoardWidth, array[BoardHeight, Cell]]
  for x in 0..<BoardWidth:
    for y in 0..<BoardHeight:
      grid[x][y] = initCell()
  # 例: 1列目に黒sui, 9列目に白suiを置く（実際の軍儀初期配置に合わせて修正可）
  var blackSui: PiecePtr
  new blackSui
  blackSui[] = initPiece(sui, black, true)
  grid[4][0].pushPiece(blackSui)

  var whiteSui: PiecePtr
  new whiteSui
  whiteSui[] = initPiece(sui, white, true)
  grid[4][8].pushPiece(whiteSui)
  # 他の駒も必要に応じて配置
  return grid

proc initBoard*(): Board =
  result.grid = placeInitialPieces()

proc getCell*(b: Board, x, y: int): Cell =
  b.grid[x][y]

proc setCell*(b: var Board, x, y: int, c: Cell) =
  b.grid[x][y] = c


# 指定座標の駒の移動可能範囲（現状suiのみ: 上下左右1マス）
proc getMovableCells*(b: Board, x, y: int): seq[(int, int)] =
  result = @[]
  let cell = b.grid[x][y]
  if cell.count == 0 or cell.pieces[cell.count-1] == nil:
    return
  let piece = cell.pieces[cell.count-1]
  case piece.kind
  of sui:
    for (dx, dy) in [(-1,0), (1,0), (0,-1), (0,1)]:
      let nx = x + dx
      let ny = y + dy
      if nx in 0..<BoardWidth and ny in 0..<BoardHeight:
        # 自分の駒がいない場合のみ移動可（簡易）
        let targetCell = b.grid[nx][ny]
        if targetCell.count == 0 or targetCell.pieces[targetCell.count-1] == nil or targetCell.pieces[targetCell.count-1].side != piece.side:
          result.add((nx, ny))
  else:
    # 他の駒の移動パターンは未実装（必要に応じて追加）
    discard