import 'package:visus_scanner/visus_scanner.dart' as visus_scanner;

void main(List<String> arguments) {
  var program = '''
scaffold {
  appbar {
    title: "My App"
  }
  body {
    column {
      children: [
        button {
          text: "Click me"
          onPressed: "handleButtonPress"
        }
      ]
    }
  }
}
''';
  var scanner = visus_scanner.Scanner(program);
  scanner.scan();
  print(scanner.tokens);
}
