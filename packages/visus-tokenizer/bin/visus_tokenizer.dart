import 'package:visus_tokenizer/visus_tokenizer.dart' as visus_tokenizer;

void main(List<String> arguments) {
  var scaffoldElement = visus_tokenizer.Token(
      visus_tokenizer.TokenType.scaffold, "scaffold", null, 1);
  print(scaffoldElement);
}
