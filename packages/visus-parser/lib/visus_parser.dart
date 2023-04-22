import 'package:visus_tokenizer/visus_tokenizer.dart';

class Color extends Component {
  final int red;
  final int green;
  final int blue;

  Color(this.red, this.green, this.blue);

  @override
  String toString() {
    return 'ColorComponent(red: $red, green: $green, blue: $blue)';
  }
}

class ScaffoldComponent {
  final AppBarComponent appBar;
  final WidgetComponent body;

  ScaffoldComponent({required this.appBar, required this.body});
}

class AppBarComponent {
  final String title;
  final Color backgroundColor;

  AppBarComponent({required this.title, required this.backgroundColor});
}

class ColumnComponent extends Component {
  final List<Component> children;
  final ColumnAttributes? attributes;

  ColumnComponent({required this.children, this.attributes});

  @override
  String toString() {
    return 'ColumnComponent(children: $children, attributes: $attributes)';
  }
}

class ButtonComponent {
  final String text;
  final String onPressed;

  ButtonComponent({required this.text, required this.onPressed});
}

class WidgetComponent {}

class UIProgram {
  final ComponentList componentList;

  UIProgram(this.componentList);
}

class ComponentList {
  final List<Component> components;

  ComponentList(this.components);
}

abstract class Component {}

class Button implements Component {
  final ButtonAttributes buttonAttributes;
  final String buttonLabel;

  Button(this.buttonAttributes, this.buttonLabel);

  @override
  String toString() => 'Button($buttonAttributes, $buttonLabel)';
}

class ColumnAttributes {
  final Map<String, dynamic> attributes;

  ColumnAttributes(this.attributes);

  @override
  String toString() {
    return attributes.values.join(', ');
  }
}

class ButtonAttributes {
  final Map<String, dynamic> attributes;

  ButtonAttributes(this.attributes);

  @override
  String toString() {
    return attributes.values.join(', ');
  }
}

class Attribute {
  final String name;
  final Object value;

  Attribute(this.name, this.value);

  @override
  String toString() => '$name: $value';
}

class Parser {
  final List<Token> _tokens;
  int _current = 0;

  Parser(this._tokens);

  List<Component> parseUIProgram() {
    return parseComponentList();
  }

  List<Component> parseComponentList() {
    final components = <Component>[];
    while (!isAtEnd()) {
      components.add(parseComponent());
    }
    return components;
  }

  Component parseComponent() {
    final token = peek();
    switch (token.type) {
      case TokenType.column:
        return parseColumnComponent();
      case TokenType.button:
        return parseButton();
      default:
        throw Exception('Expected component, got ${token.lexeme}');
    }
  }

  ColumnComponent parseColumnComponent() {
    expect(TokenType.column);

    // Parse dos atributos
    // final attributes = parseColumnAttributes();

    if (getNextToken().type != TokenType.colon) {
      throw Exception("Expected ':' after column attributes");
    }

    // Verifica se o próximo token é uma abertura de chaves
    if (getNextToken().type != TokenType.lbracket) {
      throw Exception("Expected '[' after column attributes");
    }

    List<Component> children = [];

    // Parse dos filhos
    while (peek().type != TokenType.rbracket) {
      children.add(parseComponent());
    }

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbracket) {
      throw Exception("Expected ']' after column children");
    }

    // Retorna o componente Column
    return ColumnComponent(
      children: children,
      // attributes: ColumnAttributes(attributes),
    );
  }

  Button parseButton() {
    expect(TokenType.button);

    final attributes = parseButtonAttributes();
    // final label = parseButtonLabel();
    final label = 'value';

    // expect(TokenType.lbrace);

    return Button(ButtonAttributes(attributes), label);
  }

  Map<String, Attribute> parseColumnAttributes() {
    final attributeMap = <String, Attribute>{};
    expect(TokenType.lbrace);

    if (!match(TokenType.rbrace)) {
      do {
        final attributeName = parseAttributeName();
        expect(TokenType.colon);
        final attributeValue = parseAttributeValue(attributeName);
        attributeMap[attributeName] = attributeValue;
      } while (match(TokenType.comma));
      expect(TokenType.rbrace);
    }

    return attributeMap;
  }

  Map<String, Attribute> parseButtonAttributes() {
    final attributeMap = <String, Attribute>{};
    expect(TokenType.lbrace);

    if (!match(TokenType.rbrace)) {
      do {
        final attributeName = parseAttributeName();
        expect(TokenType.colon);
        final attributeValue = parseAttributeValue(attributeName);
        attributeMap[attributeName] = attributeValue;
      } while (match(TokenType.comma));
      expect(TokenType.rbrace);
    }

    return attributeMap;
  }

  String parseAttributeName() {
    final token = expect(TokenType.text);
    return token.lexeme;
  }

  Attribute parseAttributeValue(String attrName) {
    final token = peek();
    switch (token.type) {
      case TokenType.stringLiteral:
        return Attribute(attrName, parseString());
      case TokenType.identifier:
        return Attribute(attrName, parseIdentifier());
      case TokenType.numberLiteral:
        return Attribute(attrName, parseNumberLiteral().toString());
      default:
        throw Exception('Expected attribute value, got ${token.lexeme}');
    }
  }

  String parseButtonLabel() {
    expect(TokenType.lbrace);
    final label = parseString();
    expect(TokenType.rbrace);
    return label;
  }

  Token getNextToken() {
    if (!isAtEnd()) {
      _current++;
    }
    return previous();
  }

  Token advance() {
    if (!isAtEnd()) {
      _current++;
    }
    return previous();
  }

  bool isAtEnd() {
    return peek().type == TokenType.eof;
  }

  Token peek() {
    return _tokens[_current];
  }

  Token previous() {
    return _tokens[_current - 1];
  }

  bool match(TokenType type) {
    if (check(type)) {
      advance();
      return true;
    }
    return false;
  }

  bool check(TokenType type) {
    if (isAtEnd()) {
      return false;
    }
    return peek().type == type;
  }

  Token expect(TokenType type) {
    if (check(type)) {
      return advance();
    }
    throw Exception('Expected $type, got ${peek().lexeme}');
  }

  String parseString() {
    final token = expect(TokenType.stringLiteral);
    return token.literal as String;
  }

  String parseIdentifier() {
    final token = expect(TokenType.identifier);
    return token.lexeme;
  }

  double parseNumberLiteral() {
    final token = expect(TokenType.numberLiteral);
    return double.parse(token.lexeme);
  }
}
