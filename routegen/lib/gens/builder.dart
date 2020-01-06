import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:route_gen_lib/route_gen_lib.dart';
import 'package:source_gen/source_gen.dart';

import 'generator_class_output_provider.dart';

RouteGenBuilder routebuilder;

Builder routeGen(BuilderOptions options) {
  if(routebuilder==null){
    routebuilder = RouteGenBuilder(options);
  }
  return routebuilder; //PartBuilder([RouteGenerator()], 'routeGen');
}

class RouteGenBuilder extends Builder {
  BuilderOptions options;

  RouteGenBuilder(this.options);

  TypeChecker get typeChecker => TypeChecker.fromRuntime(RouteGen);
  var outputProvider = GeneratorClassOutputProvider();

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    String outputFilePath = "lib/navigator/";
    if (options.config.containsKey("output_path")) {
      outputFilePath = options.config["output_path"].toString();
      if (outputFilePath.contains(".dart")) {
        var splitForFileName = outputFilePath.split("/");
        var fileName = splitForFileName[splitForFileName.length - 1];
        outputProvider.className = ModuleSplitter.convertToCamelCase(
            camelCase, fileName.replaceAll(".dart", ""));
        outputFilePath = outputFilePath.replaceAll(fileName, "");
      }
    }
    if (options.config.containsKey("class_name")) {
      outputProvider.className = options.config["class_name"].toString();
    }
    if (options.config.containsKey("modules_route_file")) {
      String moduleGeneratedOutputFilesLink =
          options.config["modules_route_file"];
      moduleGeneratedOutputFilesLink.split(",").forEach((module) {
        var moduleSplitter = ModuleSplitter()..generateSplit(module);
        outputProvider.modules[moduleSplitter.modulePackage] = moduleSplitter;
      });
    }
    var output = await getContentStream(buildStep);
    if (output != null) {
      File file = File(outputFilePath +
          "/${ModuleSplitter.convertToSnakeCase(outputProvider.className)}.dart");
      if (file.existsSync()) file.delete(recursive: true);
      file.createSync(recursive: true);
      file.writeAsString(outputProvider.fullClassToWrite);
    }
    return;
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        ".dart": [".route.dart"]
      };

  Future<String> getContentStream(BuildStep buildStep) async {
    var isAnnotationFound = false;
    print("-------------------getContentStream----------------------");

    StringBuffer buffer = StringBuffer();

    var lib = await buildStep.inputLibrary;

    lib.topLevelElements.forEach((topLevelItems) {
      var libraryReader = LibraryReader(topLevelItems.enclosingElement.library);
      libraryReader.classes.forEach((classItem) {});
      for (var annotatedElement in libraryReader.annotatedWith(typeChecker)) {
        if (annotatedElement.element.name == topLevelItems.name) {
          outputProvider.generateForAnnotatedElement(
              topLevelItems, annotatedElement.annotation, buildStep);
          buffer.writeln(outputProvider.fullClassToWrite);
          isAnnotationFound = true;
        }
      }
    });

    if (isAnnotationFound)
      return buffer.toString();
    else
      return null;
  }
}
