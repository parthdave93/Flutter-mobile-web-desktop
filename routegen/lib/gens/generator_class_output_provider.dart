import 'dart:io';

import 'package:build/build.dart';
import 'package:routegen/gens/class_visitor.dart';
import 'package:routegen/gens/route_container.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
import 'dart:collection';

const snakeCase = r'(_\w+)';
const packageCase = r'(.\w+)';
const camelCase = r'[A-Z\s]+';

class GeneratorClassOutputProvider {
  var className = "RoutePusher";
  var headers = Set<String>();
  var mapOfRouteAndClass = HashMap<String, RouteContainer>();
  var methods = HashMap<String, String>();
  var modules = Map<String, ModuleSplitter>();

  var errors = List<String>();

  GeneratorClassOutputProvider() {
    //default headers
    headers.add("import 'package:meta/meta.dart';");
    headers.add("import 'package:flutter/widgets.dart';");
    headers.add("import 'package:meta/meta.dart';");
    headers.add("import 'package:flutter/material.dart';");
  }

  String moduleImports() {
    modules.forEach((package, module) {
      module.differentClassNameImport = ModuleSplitter.convertToCamelCase(snakeCase, module.modulePackage);
      headers.add("import 'package:${module.originalPath}' as ${module.differentClassNameImport};");
    });
  }

  String get allMethods {
    StringBuffer methodBuffer = StringBuffer();
    methods.forEach((libUri, method) {
      methodBuffer.writeln(method);
    });
    return methodBuffer.toString();
  }

  String get allHeaders {
    StringBuffer headerBuffer = StringBuffer();
    headers.forEach((method) {
      headerBuffer.writeln(method);
    });
    return headerBuffer.toString();
  }

  String get allConstants {
    StringBuffer constantBuffer = StringBuffer();
    mapOfRouteAndClass.forEach((key, routes) {
      constantBuffer.writeln(getRouteConstant(routes.routeName));
    });
    return constantBuffer.toString();
  }

  String get fullClassToWrite {
    moduleImports();
    StringBuffer stringBuffer = StringBuffer();
    if (errors.length == 0) {
      var methodToWrite = allMethods;
      stringBuffer.writeln(generatedTopComments);
      stringBuffer.writeln(allHeaders);
      stringBuffer.writeln(allConstants);
      stringBuffer.writeln("class $className{");
      stringBuffer.write(moduleVariables);
      stringBuffer.write(methodToWrite);
      stringBuffer.writeln(commonGenerateRouteMethod);
      stringBuffer.writeln(generateHandler());
      stringBuffer.writeln("}");
    } else {
      errors.forEach((error) {
        stringBuffer.writeln(error);
      });
    }
    return stringBuffer.toString();
  }

  String getModuleClassName(ModuleSplitter module) {
    var className = module.className;
    if (module.differentClassNameImport != null) {
      className = module.differentClassNameImport + "." + className;
    }
    return className;
  }

  String get moduleVariables {
    StringBuffer modulesBuffer = StringBuffer();
    modules.forEach((package, module) {
      var variableName = module.className.substring(0, 1).toLowerCase() + module.className.substring(1);
      var className = getModuleClassName(module);

      if (module.differentClassNameImport != null) {
        variableName = module.className;
        variableName = module.differentClassNameImport + variableName;
      }

      modulesBuffer.writeln("${getTabs(1)}var ${variableNameTransformation(variableName)} = ${className}();");
    });
    return modulesBuffer.toString();
  }

  String get generatedTopComments {
    StringBuffer commentBuffer = StringBuffer();
    commentBuffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    commentBuffer.writeln("// *****************************************************************");
    commentBuffer.writeln("// Route Generator By Parth Dave ");
    commentBuffer.writeln("// *****************************************************************");
    commentBuffer.writeln();

    return commentBuffer.toString();
  }

  String get commonGenerateRouteMethod {
    var buffer = StringBuffer();
    buffer.writeln("${getTabs(1)}static generateRouteFor(Widget widget){");
    buffer.writeln("${getTabs(2)}return MaterialPageRoute(");
    buffer.writeln("${getTabs(3)}builder: (_)=> widget");
    buffer.writeln("${getTabs(2)});");
    buffer.writeln("${getTabs(1)}}");
    return buffer.toString();
  }

  String generateHandler() {
    var buffer = StringBuffer();
    buffer.writeln("${getTabs(1)}static Route<dynamic> generateRoutes(RouteSettings routeSettings){");

    if (modules.length > 0) {
      modules.forEach((package, module) {
        var moduleFoundName =
            "${variableNameTransformation(ModuleSplitter.convertToCamelCase(snakeCase, package))}RouteFound";
        buffer.writeln(
            "${getTabs(2)}var $moduleFoundName = ${getModuleClassName(module)}.generateRoutes(routeSettings);");
        buffer.writeln("${getTabs(2)}if(${moduleFoundName} !=null){");
        buffer.writeln("${getTabs(3)}return ${moduleFoundName};");
        buffer.writeln("${getTabs(2)}}");
      });
    }

    buffer.writeln("${getTabs(2)}Widget openScreen;");
    buffer.writeln("${getTabs(2)}switch(routeSettings.name){");
    mapOfRouteAndClass.forEach((key, value) {
      buffer.writeln("${getTabs(3)}case ROUTE_NAME_${value.routeName.toUpperCase()}:");
      buffer.writeln("${getTabs(4)}openScreen = ${value.routeOrigin}(${value.methodParamString});");
      buffer.writeln("${getTabs(4)}break;");
    });
    buffer.writeln("${getTabs(3)}}");
    buffer.writeln("${getTabs(2)}return generateRouteFor(openScreen);");
    buffer.writeln("${getTabs(1)}}");
    return buffer.toString();
  }

  String getTabs(int count) {
    return "\t" * count;
  }

  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    var visitor = ClassVisitor();
    element.visitChildren(visitor);

    String routeName = annotation.read('routeName').stringValue;
    DartType paramObjectType = annotation.read('paramClass').typeValue;

    String paramsForScreen = parseHeaders(element, paramObjectType);

    var routeContainer = RouteContainer(
        params: paramObjectType,
        constantRouteName: "ROUTE_NAME_${routeName.toUpperCase()}",
        routeOrigin: element.displayName,
        routeName: routeName,
        methodParamString: generateRouteChecksForConstructors(visitor, paramObjectType));
    mapOfRouteAndClass[element.librarySource.uri.toString()] = routeContainer;

    methods[element.librarySource.uri.toString()] = addRoutingMethodInList(routeName, paramsForScreen);
  }

  generateRouteChecksForConstructors(ClassVisitor visitor, DartType paramObjectType) {
    StringBuffer method = StringBuffer();
    bool isParameterFound = false;
    visitor.constructorParameters.forEach((parameters) {
      if (paramObjectType == parameters.type) {
        isParameterFound = true;
        if (parameters.isOptional)
          method.write("${parameters.name}: routeSettings.arguments as $paramObjectType");
        else
          method.write("routeSettings.arguments as $paramObjectType");
      }
    });
    if (!isParameterFound) {
      errors.add("Please add $paramObjectType as parameter for ${visitor.className}");
      throwException("Please add $paramObjectType as parameter for ${visitor.className}");
    }
    return method.toString();
  }

  /// generates routing method to be written in the file
  addRoutingMethodInList(String routeName, String paramsForScreen) {
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer
        .writeln("${getTabs(1)}open${capitalize(routeName)}({@required BuildContext context, $paramsForScreen}){");
    stringBuffer.writeln(
        "${getTabs(2)}Navigator.of(context).pushNamed(ROUTE_NAME_${routeName.toUpperCase()}, arguments: params);");
    stringBuffer.writeln("${getTabs(1)}}");
    return stringBuffer.toString();
  }

  /// Parse Headers method will take [element], [paramObjectType] for generating header for file imports
  parseHeaders(Element element, DartType paramObjectType) {
    String paramsForScreen = "";
    if (paramObjectType != null) {
      headers.add("import '${element.source.uri.toString()}';");

      if (!checkIfPrimaryType(paramObjectType))
        headers.add("import '${paramObjectType.element.source.uri.toString()}';");
      paramsForScreen = "@required $paramObjectType params";
    }
    return paramsForScreen;
  }

  getRouteConstant(String routeName) {
    return "const ROUTE_NAME_${routeName.toUpperCase()} = \"$routeName\";";
  }

  throwException(value) {
    throw Exception(value);
  }

  /// checking if the param is of core then we don't need to import it
  bool checkIfPrimaryType(DartType param) {
    return (param.isDartCoreString ||
        param.isDartCoreBool ||
        param.isDartCoreNum ||
        param.isDartCoreList ||
        param.isDartCoreInt ||
        param.isDartCoreDouble ||
        param.isDartCoreMap ||
        param.isDartCoreSet);
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  String variableNameTransformation(String s) => s[0].toLowerCase() + s.substring(1);
}

class ModuleSplitter {
  String originalPath;
  String modulePackage;
  String fileName;
  String routeName;
  String className;
  String differentClassNameImport;

  String generateSplit(String fileUri) {
    originalPath = fileUri;
    var splitString = fileUri.split("/");
    modulePackage = splitString[0];
    fileName = splitString[splitString.length - 1];
    className = convertToCamelCase(snakeCase, fileName.replaceAll(".dart", ""));
  }

  static String convertToCamelCase(String matchFor, String value) {
    try {
      String newValue = value.substring(0, 1).toUpperCase() + value.substring(1);
      RegExp regExp = new RegExp(
        matchFor,
        caseSensitive: false,
      );
      var firstMatch = regExp.firstMatch(newValue);
      while (firstMatch != null) {
        newValue = newValue.substring(0, firstMatch.start) +
            newValue.substring(firstMatch.start + 1, firstMatch.start + 2).toUpperCase() +
            newValue.substring(firstMatch.start + 2);
        firstMatch = regExp.firstMatch(newValue);
      }
      return newValue;
    } catch (e) {
      print(e);
    }
    return "";
  }

  static String convertToSnakeCase(String value) {
    try {
      String newValue = value.substring(0, 1).toLowerCase() + value.substring(1);
      RegExp regExp = new RegExp(
        camelCase,
        caseSensitive: true,
      );
      var firstMatch = regExp.firstMatch(newValue);
      while (firstMatch != null) {
        newValue = newValue.substring(0, firstMatch.start) +
            "_" +
            newValue.substring(firstMatch.start, firstMatch.start + 1).toLowerCase() +
            newValue.substring(firstMatch.start + 1);
        firstMatch = regExp.firstMatch(newValue);
      }
      return newValue;
    } catch (e) {
      print(e);
    }
    return "";
  }
}
