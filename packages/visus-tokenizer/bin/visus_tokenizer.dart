import 'package:visus_tokenizer/visus_tokenizer.dart' as visus_tokenizer;

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

  var tokenizer = visus_tokenizer.Tokenizer(program);
  tokenizer.tokenize();
  print(tokenizer.tokens);
}
