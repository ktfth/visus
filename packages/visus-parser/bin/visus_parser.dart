import 'package:visus_scanner/visus_scanner.dart';
import 'package:visus_parser/visus_parser.dart' as visus_parser;

void main(List<String> arguments) {
  var program = '''
scaffold {
  appbar {
    title: "My App"
  }
  body {
    column [
      button {
        text: "Click me"
      }
    ]
  }
}''';
  var scanner = Scanner(program);
  scanner.scan();
  var parser = visus_parser.Parser(scanner.tokens);
  var ast = parser.parseUIProgram();
  print(ast);
}
