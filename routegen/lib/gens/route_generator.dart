import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:route_gen_lib/route_gen_lib.dart';
import 'package:source_gen/source_gen.dart';

class RouteGenerator extends GeneratorForAnnotation<RouteGen> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    StringBuffer stringBuffer = StringBuffer();

    String routeName = annotation.read('routeName').stringValue;
    DartType paramObjectType = annotation.read('paramClass').typeValue;

    //check for asserts
    String paramsForScreen = "";
    if(paramObjectType!=null){
      paramsForScreen = "@required $paramObjectType params";
    }
    stringBuffer.writeln("import 'package:meta/meta.dart';");
    stringBuffer.writeln("import 'package:flutter/widgets.dart';");
    stringBuffer.writeln("const ${routeName.toUpperCase()} = \"routeName\";");
    stringBuffer.writeln("class Router{");
    stringBuffer.writeln("open$routeName({@required BuildContext context, $paramsForScreen}){");
    stringBuffer.writeln("Navigator.of(context).pushNamed(${routeName.toUpperCase()}, arguments: params);");
    stringBuffer.writeln("}");
    stringBuffer.writeln("}");



    return stringBuffer.toString();
  }
}