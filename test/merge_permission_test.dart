import 'package:test/test.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

void main() {
  group('UtilQuery.checkPermissions', () {
    late Map<String, Permission> permissions;

    setUp(() {
      permissions = {
        'baseUsers': Permission([
          EnumQueryType.search,
          EnumQueryType.searchOne,
        ]),
        'userDetail': Permission([EnumQueryType.search]),
        'mergedUsers': Permission([EnumQueryType.merge]),
      };
    });

    test('permissions == null allows everything', () {
      final q = Query(type: EnumQueryType.search, target: 'anyCollection');

      expect(UtilQuery.checkPermissions(q, null), isTrue);
    });

    test('non-merge query allowed', () {
      final q = Query(type: EnumQueryType.search, target: 'baseUsers');

      expect(UtilQuery.checkPermissions(q, permissions), isTrue);
    });

    test('merge query not allowed by permission', () {
      final permissions = {
        'baseUsers': Permission([EnumQueryType.search]),
        'mergedUsers': Permission([]), // merge 不可,
      };
      final mqp = MergeQueryParams(
        base: 'baseUsers',
        source: [],
        output: 'mergedUsers',
        relationKey: 'id',
        sourceKeys: [],
        dslTmp: {},
      );
      final q = Query(
        type: EnumQueryType.merge,
        target: 'baseUsers',
        mergeQueryParams: mqp,
      );
      expect(UtilQuery.checkPermissions(q, permissions), isFalse);
    });

    test('non-merge query missing permission', () {
      final q = Query(type: EnumQueryType.search, target: 'unknownCollection');

      expect(UtilQuery.checkPermissions(q, {}), isFalse);
    });

    test('merge query allowed', () {
      final mqp = MergeQueryParams(
        base: 'baseUsers',
        source: ['userDetail'],
        output: 'mergedUsers',
        relationKey: 'a',
        // non use test value
        sourceKeys: ['a', 'b'],
        // non use test value
        dslTmp: {}, // non use test value
      );

      final q = Query(
        type: EnumQueryType.merge,
        target: 'baseUsers',
        mergeQueryParams: mqp,
      );

      expect(UtilQuery.checkPermissions(q, permissions), isTrue);
    });

    test('merge query base not readable', () {
      final perms = Map<String, Permission>.from(permissions);
      perms['baseUsers'] = Permission([]);

      final mqp = MergeQueryParams(
        base: 'baseUsers',
        source: ['userDetail'],
        output: 'mergedUsers',
        relationKey: 'a',
        sourceKeys: ['a', 'b'],
        dslTmp: {},
      );

      final q = Query(
        type: EnumQueryType.merge,
        target: 'baseUsers',
        mergeQueryParams: mqp,
      );

      expect(UtilQuery.checkPermissions(q, perms), isFalse);
    });

    test('merge query source not readable', () {
      final perms = Map<String, Permission>.from(permissions);
      perms['userDetail'] = Permission([]);

      final mqp = MergeQueryParams(
        base: 'baseUsers',
        source: ['userDetail'],
        output: 'mergedUsers',
        relationKey: 'a',
        sourceKeys: ['a', 'b'],
        dslTmp: {},
      );

      final q = Query(
        type: EnumQueryType.merge,
        target: 'baseUsers',
        mergeQueryParams: mqp,
      );

      expect(UtilQuery.checkPermissions(q, perms), isFalse);
    });

    test('merge query output not mergeable', () {
      final perms = Map<String, Permission>.from(permissions);
      perms['mergedUsers'] = Permission([]);

      final mqp = MergeQueryParams(
        base: 'baseUsers',
        source: ['userDetail'],
        output: 'mergedUsers',
        relationKey: 'a',
        sourceKeys: ['a', 'b'],
        dslTmp: {},
      );

      final q = Query(
        type: EnumQueryType.merge,
        target: 'baseUsers',
        mergeQueryParams: mqp,
      );

      expect(UtilQuery.checkPermissions(q, perms), isFalse);
    });

    test('merge query with serialBase', () {
      final perms = Map<String, Permission>.from(permissions);
      perms['serialBase'] = Permission([EnumQueryType.search]);

      final mqp = MergeQueryParams(
        base: 'baseUsers',
        source: ['userDetail'],
        output: 'mergedUsers',
        serialBase: 'serialBase',
        relationKey: 'a',
        sourceKeys: ['a', 'b'],
        dslTmp: {},
      );

      final q = Query(
        type: EnumQueryType.merge,
        target: 'baseUsers',
        mergeQueryParams: mqp,
      );

      expect(UtilQuery.checkPermissions(q, perms), isTrue);
    });

    test('merge query without MergeQueryParams throws', () {
      final q = Query(
        type: EnumQueryType.merge,
        target: 'baseUsers',
        mergeQueryParams: null,
      );

      expect(
        () => UtilQuery.checkPermissions(q, permissions),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
