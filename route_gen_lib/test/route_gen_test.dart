import 'package:route_gen_lib/route_gen_lib.dart';
import 'package:test/test.dart';

void main() {
  group('Route gen annotation', () {
    test('must have a non-null routeName', () {
      expect(() => RouteGen(routeName: null), throwsA(TypeMatcher<AssertionError>()));
    });

    test('does not need to have a params', () {
      final todo = RouteGen(routeName: 'name');
      expect(todo.paramClass, null);
    });

    test('check param class', () {
      final todo = RouteGen(routeName: 'name', paramClass: NoParam);
      expect(todo.paramClass, NoParam);
    });
  });
}
