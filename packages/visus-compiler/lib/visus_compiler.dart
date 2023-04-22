import 'package:visus_parser/visus_parser.dart';

class Compiler {
  final List<Component> ast;

  Compiler(this.ast);

  String compile() {
    return compileUIProgram(ast);
  }

  String compileUIProgram(List<Component> components) {
    String code = '';
    for (Component component in components) {
      code += compileButton(component as Button);
    }
    return code;
  }

  String compileButton(Button button) {
    final textAttr = button.buttonAttributes.attributes['text'];
    final onPressedAttr = null;

    final text = textAttr != null ? textAttr.value : 'Button';
    final onPressed = onPressedAttr != null ? onPressedAttr.value : '() {}';

    final code = '''
ElevatedButton(
  onPressed: $onPressed,
  child: Text('$text'),
)
''';

    return code;
  }
}
