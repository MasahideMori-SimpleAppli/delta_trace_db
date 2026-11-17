import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:test/test.dart';

void main() {
  test('quotes, line breaks, BOM and trailing empty lines', () {
    final items = UtilCsv.toItems(
      '﻿name,price,memo\r\n"Smith, J","10.50","a ""b""\nc"\r\n2,,\r\n\r\n',
    );
    expect(items, [
      {'name': 'Smith, J', 'price': '10.50', 'memo': 'a "b"\nc'},
      {'name': '2', 'price': '', 'memo': ''},
    ]);
  });

  test('errors report the line where the record starts', () {
    CsvFormatError err(String text) {
      try {
        UtilCsv.toItems(text);
      } on CsvFormatError catch (e) {
        return e;
      }
      fail('no error');
    }

    expect(err('a,a\n1,2').kind, EnumCsvErrorKind.header);
    expect(err('a,\n1,2').kind, EnumCsvErrorKind.header);
    final c = err('a,b\n"x\ny",1\n1');
    expect((c.kind, c.line), (EnumCsvErrorKind.columnCount, 4));
    final f = err('a,b\n"x"y,1');
    expect((f.kind, f.line), (EnumCsvErrorKind.format, 2));
    final u = err('a,b\n1,"x');
    expect((u.kind, u.line), (EnumCsvErrorKind.format, 2));
  });

  test('addCsv and clearAddCsv queries', () {
    final db = DeltaTraceDatabase();
    final bad = QueryBuilder.addCsv(target: 'item', csvText: 'a,b\n1').build();
    final rBad = db.executeQuery(bad);
    expect(rBad.isSuccess, false);
    expect(rBad.errorMessage, 'CsvFormatError(columnCount, line 2)');
    expect(db.findCollection('item'), null);

    final add = QueryBuilder.addCsv(
      target: 'item',
      csvText: 'id,name\n,x\n,y',
      serialKey: 'id',
      returnData: true,
    ).build();
    final r1 = db.executeQuery(Query.fromDict(add.toDict()));
    expect(r1.isSuccess, true);
    expect(r1.type, EnumQueryType.addCsv);
    expect(r1.result, [
      {'id': 0, 'name': 'x'},
      {'id': 1, 'name': 'y'},
    ]);

    final clearAdd = QueryBuilder.clearAddCsv(
      target: 'item',
      csvText: 'id,name\n,z',
      serialKey: 'id',
      resetSerial: true,
    ).build();
    final r2 = db.executeQuery(clearAdd);
    expect(r2.isSuccess, true);
    expect(db.collection('item').raw, [
      {'id': 0, 'name': 'z'},
    ]);
  });
}
