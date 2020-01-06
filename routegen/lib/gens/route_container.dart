import 'package:meta/meta.dart';
import 'package:analyzer/dart/element/type.dart';

class RouteContainer {
  final DartType params;
  final String constantRouteName;
  final String routeName;
  final String routeOrigin;
  final String methodParamString;

  RouteContainer(
      {@required this.params,
        @required this.constantRouteName,
      @required this.routeName,
      @required this.routeOrigin,
      this.methodParamString});
}
