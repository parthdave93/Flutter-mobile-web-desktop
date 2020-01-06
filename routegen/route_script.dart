import 'dart:convert';
import 'dart:io';

const routeClassName = "RoutePusher";
const routeFilePath = "lib/route";
const modulesRouteFiles = [];//["flutter_anotherexample_module/route/example_route.dart"];

const command = "flutter packages pub run build_runner watch "
    " --delete-conflicting-outputs -v "
    "--define \"routegen=output_path=$routeFilePath\" "
    "--define \"routegen=class_name=$routeClassName\"";

main(List<String> arguments) async {
  var arguments = command.split(" ");
  modulesRouteFiles.forEach((module) {
    arguments.add("--define");
    arguments.add("routegen=modules_route_file=$module");
  });

  var process = await Process.start('bash', arguments, runInShell: true);
  process.stdout.transform(utf8.decoder).listen((data) {
    print(data);
  }).onError((e) {
    print(e);
  });
}


/*
var arguments = [
  "flutter",
  "packages",
  "pub",
  "run",
  "build_runner",
  "build",
  "--delete-conflicting-outputs",
  "--define",
  "routegen=output_path=$routeFilePath",
  "--define",
  "routegen=class_name=$routeClassName"
];*/
