import 'package:visus_tokenizer/visus_tokenizer.dart';

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
      case TokenType.button:
        return parseButton();
      default:
        throw Exception('Expected button, got ${token.lexeme}');
    }
  }

  Button parseButton() {
    expect(TokenType.button);

    final attributes = parseButtonAttributes();
    // final label = parseButtonLabel();
    final label = 'value';

    // expect(TokenType.lbrace);

    return Button(ButtonAttributes(attributes), label);
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
