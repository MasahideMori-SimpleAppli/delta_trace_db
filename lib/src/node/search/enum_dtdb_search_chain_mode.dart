/// 探索時のオブジェクトの連結モードです。
enum EnumDTDBSearchChainMode{
  // 次のパスとして連結します。AndやOrの計算が一旦区切られます。
  nextPath,
  // And演算した結果が得られるオブジェクトになります。
  calcAnd,
  // Or演算した結果が得られるオブジェクトになります。
  calcOr
}