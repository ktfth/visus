import 'dart:io';

import 'package:visus_scanner/visus_scanner.dart';
import 'package:visus_parser/visus_parser.dart';
import 'package:visus_compiler/visus_compiler.dart' as visus_compiler;

void main(List<String> arguments) {
  var program = '''
button {
  text: "Yeah!"
}
''';
  var scanner = Scanner(program);
  scanner.scan();
  var parser = Parser(scanner.tokens);
  var ast = parser.parseUIProgram();
  var compiler = visus_compiler.Compiler(ast);
  var code = compiler.compile();
  stdout.write(code);
}
