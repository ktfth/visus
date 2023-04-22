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
      if (component is ColumnComponent) {
        code += compileColumn(component);
      } else if (component is Button) {
        code += compileButton(component);
      }
    }
    return code;
  }

  String compileColumn(ColumnComponent column) {
    String code = 'Column(\n';
    code += '  children: [\n';
    for (Component child in column.children) {
      if (child is Button) {
        var compiledButton = compileButton(child);
        var index = 0;
        var lastLineIndex = compiledButton.split('\n').length - 1;
        compiledButton.split('\n').forEach((line) {
          code += '    $line';
          if (index == lastLineIndex) {
            code += ',\n';
          } else {
            code += '\n';
          }
          index++;
        });
      }
      // adicione aqui qualquer outro tipo de componente que desejar suportar
    }
    code += '  ]\n';
    code += ')';
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
)''';

    return code;
  }
}
