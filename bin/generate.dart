#!/usr/bin/env dart
import 'dart:io';

import 'package:args/args.dart';
import 'package:r_dart/src/arguments.dart';
import 'package:r_dart/src/generator/generator.dart';
import 'package:r_dart/src/utils/utils.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  final arguments = CommandLineArguments()
    ..parse(args);

  final configRaw = safeCast<YamlMap>(loadYaml(File(arguments.pubspecFilename).absolute.readAsStringSync()));
  final config = Config.parsePubspecConfig(configRaw ?? YamlMap());

  final contents = generateFile(config);

  final outoutFile = File(arguments.outputFilename);
  outoutFile.createSync(recursive: true);
  outoutFile.writeAsStringSync(contents);

  print("${outoutFile.path} generated successfully");
}

class CommandLineArguments {
  String pubspecFilename;
  String outputFilename;

  void parse(List<String> args) {
    ArgParser()
      ..addOption(
        "pubspec-file",
        defaultsTo: 'pubspec.yaml',
        callback: (value) => pubspecFilename = safeCast(value),
        help: 'Specify the pubspec file.',
      )
      ..addOption(
        "output-file",
        defaultsTo: 'lib/generated/r.dart',
        callback: (value) => outputFilename = safeCast(value),
        help: 'Specify the output file.',
      )
      ..parse(args);
  }
}