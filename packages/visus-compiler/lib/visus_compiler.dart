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
      if (component is ScaffoldComponent) {
        code += compileScaffold(component);
      } else if (component is AppBarComponent) {
        code += compileAppBar(component);
      } else if (component is BodyComponent) {
        code += compileBody(component);
      } else if (component is ColumnComponent) {
        code += compileColumn(component);
      } else if (component is Button) {
        code += compileButton(component);
      }
    }
    String header = '${code.split('\n')[0]}\n';
    code = header +
        code.split('\n').sublist(1).map((line) {
          return '    $line';
        }).join('\n');
    String wrapper = '''
import 'package:flutter/material.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return $code;
  }
}''';
    return wrapper;
  }

  // Write the scaffold component compile function
  String compileScaffold(ScaffoldComponent scaffold) {
    String code = 'Scaffold(\n';
    code += '  appBar: ';
    code += compileAppBar(scaffold.appBar);
    code += ',\n';
    code += '  body: ';
    code += compileBody(scaffold.body as BodyComponent);
    code += ',\n';
    code += ')';
    return code;
  }

  // Write the appbar component compile function
  String compileAppBar(AppBarComponent appBar) {
    String code = 'AppBar(\n';
    code += '    title: Text("${appBar.title}"),\n';
    code += '  )';
    return code;
  }

  // Write the body component compile function
  String compileBody(BodyComponent body) {
    String code = 'Body(\n';
    code += '    child: ';
    code += compileColumn(body.column[0] as ColumnComponent);
    code += ',\n';
    code += '  )';
    return code;
  }

  String compileColumn(ColumnComponent column) {
    String code = 'Column(\n';
    code += '        children: [\n';
    for (Component child in column.children) {
      if (child is Button) {
        var compiledButton = compileButton(child);
        var index = 0;
        var lastLineIndex = compiledButton.split('\n').length - 1;
        compiledButton.split('\n').forEach((line) {
          code += '            $line';
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
    code += '        ]\n';
    code += '    )';
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
