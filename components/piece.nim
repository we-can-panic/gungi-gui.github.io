type
  PieceType* = enum
    sui, taisho, chujo, shosho, samurai, yari, uma, shinobi, toride, hyou, hou, yumi, tsutsu, bou

  Side* = enum
    black, white

  Piece* = object
    kind*: PieceType
    side*: Side

  PiecePtr* = ref Piece

  Cell* = object
    pieces*: array[3, PiecePtr] # 0:最下段, 2:最上段
    count*: int # 現在積まれている駒の数（0〜3）

proc initPiece*(kind: PieceType, side: Side): Piece =
  Piece(kind: kind, side: side)

proc initCell*(): Cell =
  Cell(pieces: [nil, nil, nil], count: 0)

# Cellに駒を積む
proc pushPiece*(c: var Cell, p: PiecePtr) =
  if c.count < 3:
    c.pieces[c.count] = p
    c.count += 1


# Cellから駒を取り出す（最上段のみ）
proc popPiece*(c: var Cell): PiecePtr =
  if c.count > 0:
    result = c.pieces[c.count-1]
    c.pieces[c.count-1] = nil
    c.count -= 1

# 最上段の駒を取得（nilなら空）
func getPiece*(c: Cell): PiecePtr =
  if c.count > 0:
    return c.pieces[c.count-1]
  else:
    return nil

# 駒の移動パターンを返す（ツケの段数によって動きが変わる）
# 戻り値は相対座標のリスト（例: [(-1,0), (1,0)] なら上下に1マス動ける）
proc getMovePattern*(kind: PieceType, stackLevel: int): seq[(int, int)] =
  # stackLevel: 0=最下段, 1=中段, 2=最上段
  case kind
  of sui:
    # 段数によって動きが変わる
    case stackLevel
    of 0: result = # 周囲8マス
      @[(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,1), (-1,1), (1,-1)]
    of 1: result = # 周囲8マス+その先の1マス
      @[(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,1), (-1,1), (1,-1),
        (-2,0), (2,0), (0,-2), (0,2), (-2,-2), (2,2), (-2,2), (2,-2)]
    of 2: result = # 周囲8マス+その先の2マス
      @[(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,1), (-1,1), (1,-1),
        (-2,0), (2,0), (0,-2), (0,2), (-2,-2), (2,2), (-2,2), (2,-2),
        (-3,0), (3,0), (0,-3), (0,3), (-3,-3), (3,3), (-3,3), (3,-3)]
    else: discard
  of taisho:
    # 縦横無制限（飛車のような動き）
    # 方向ベクトルのみ返し、Board側で連続移動を判定する
    case stackLevel
    of 0: result = # 上下左右 + 斜め1マス
      @[(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,1), (-1,1), (1,-1)]
    of 1: result = # 上下左右 + 斜め1マス + その先の1マス
      @[(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,1), (-1,1), (1,-1),
                                      (-2,-2), (2,2), (-2,2), (2,-2)]
    of 2: result = # 上下左右 + 斜め1マス + その先の1マス + その先の2マス
      @[(-1,0), (1,0), (0,-1), (0,1),   (-1,-1), (1,1), (-1,1), (1,-1),
        (-2,-2), (2,2), (-2,2), (2,-2), (-3,-3), (3,3), (-3,3), (3,-3)]
    else: discard
  of chujo:
    # 斜め4方向無制限（角のような動き）
    case stackLevel
    of 0: result = # 斜め4方向 + 縦横1マス
      @[(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,1), (-1,1), (1,-1)]
    of 1: result = # 斜め4方向 + 縦横1マス + その先の1マス
      @[(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,1), (-1,1), (1,-1),
        (-2,0), (2,0), (0,-2), (0,2)]
    of 2: result = # 斜め4方向 + 縦横1マス + その先の1マス + その先の2マス
      @[(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,1), (-1,1), (1,-1),
        (-2,0), (2,0), (0,-2), (0,2), (-3,0), (3,0), (0,-3), (0,3)]
    else: discard
  else:
    # 他の駒は動きがない（例: shosho, samurai, yari, uma, shinobi, toride, hyou, hou, yumi, tsutsu, bou）
    result = @[]