/// (en) An enum that defines the type of query.
///
/// (ja) クエリの種類を定義したEnum。
enum EnumQueryType {
  add,
  update,
  updateOne,
  delete,
  search,
  getAll,
  conformToTemplate, // DB shape change.
  renameField, // DB field name change.
  count, // get all items count.
  clear, // delete all items.
  clearAdd, // clear then add
}
