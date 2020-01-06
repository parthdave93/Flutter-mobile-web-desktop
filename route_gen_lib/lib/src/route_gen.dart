import 'package:meta/meta.dart';

class RouteGen{
  final String routeName;
  final Type paramClass;

  const RouteGen({@required this.routeName, this.paramClass}) : assert(routeName != null);
}


class NoParam{

}

const UnknownRoute = "unknown_route";
const NetworkError = "network_error";