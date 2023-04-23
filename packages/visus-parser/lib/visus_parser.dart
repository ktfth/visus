import 'package:visus_tokenizer/visus_tokenizer.dart';

class Color extends WidgetComponent {
  final int red;
  final int green;
  final int blue;

  Color(this.red, this.green, this.blue);

  @override
  String toString() {
    return 'ColorComponent(red: $red, green: $green, blue: $blue)';
  }
}

class TitleComponent extends WidgetComponent {
  final String title;

  TitleComponent(this.title);

  @override
  String toString() {
    return 'TitleComponent(title: $title)';
  }
}

class ScaffoldComponent extends WidgetComponent {
  final AppBarComponent appBar;
  final Component? body;

  ScaffoldComponent({required this.appBar, required this.body});

  @override
  String toString() {
    return 'ScaffoldComponent(appBar: $appBar, body: $body)';
  }
}

class AppBarComponent extends WidgetComponent {
  final String title;
  final Color backgroundColor;

  AppBarComponent({required this.title, required this.backgroundColor});

  @override
  String toString() {
    return 'AppBarComponent(title: $title, backgroundColor: $backgroundColor)';
  }
}

class ColumnComponent extends WidgetComponent {
  final List<Component> children;
  final ColumnAttributes? attributes;

  ColumnComponent({required this.children, this.attributes});

  @override
  String toString() {
    return 'ColumnComponent(children: $children, attributes: $attributes)';
  }
}

class ButtonComponent extends WidgetComponent {
  final String text;
  final String onPressed;

  ButtonComponent({required this.text, required this.onPressed});
}

class WidgetComponent extends Component {
  @override
  String toString() {
    return 'WidgetComponent()';
  }
}

class BodyComponent extends WidgetComponent {
  final List<WidgetComponent> column;

  BodyComponent(this.column);

  @override
  String toString() {
    return 'BodyComponent(column: $column)';
  }
}

class UIProgram extends Component {
  final ComponentList componentList;

  UIProgram(this.componentList);

  @override
  String toString() {
    return 'UIProgram(componentList: $componentList)';
  }
}

class ComponentList {
  final List<Component> components;

  ComponentList(this.components);

  @override
  String toString() {
    return 'ComponentList(components: $components)';
  }
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
      case TokenType.scaffold:
        return parseScaffoldComponent();
      case TokenType.column:
        return parseColumnComponent();
      case TokenType.button:
        return parseButton();
      default:
        throw Exception('Expected component, got ${token.lexeme}');
    }
  }

  ScaffoldComponent parseScaffoldComponent() {
    expect(TokenType.scaffold);

    // Parse dos atributos
    final attributes = parseScaffoldAttributes();

    // Verifica se o próximo token é uma abertura de chaves
    if (getNextToken().type != TokenType.lbrace) {
      throw Exception("Expected '{' after scaffold attributes");
    }

    // Parse dos filhos
    final children = parseScaffoldChildren();

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbrace) {
      throw Exception("Expected '}' after scaffold children");
    }

    // Retorna o componente Scaffold
    return ScaffoldComponent(
      appBar: children['appBar'] as AppBarComponent,
      body: children['body'],
    );
  }

  Map<String, dynamic> parseScaffoldAttributes() {
    final attributes = <String, dynamic>{};

    while (peek().type != TokenType.lbrace) {
      final attribute = parseAttribute();
      attributes[attribute.name] = attribute.value;
    }

    return attributes;
  }

  // Write a function to parseAttribute
  Attribute parseAttribute() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.title:
        if (peek().type == TokenType.colon) {
          getNextToken();
        }
        return Attribute('title', parseString());
      case TokenType.backgroundColor:
        return Attribute('backgroundColor', parseColor());
      default:
        throw Exception('Expected attribute, got ${token.lexeme}');
    }
  }

  String parseString() {
    final token = expect(TokenType.stringLiteral);
    return token.literal as String;
  }

  Color parseColor() {
    final token = getNextToken();
    if (token.type != TokenType.color) {
      throw Exception('Expected color, got ${token.lexeme}');
    }
    return Color(
      int.parse(token.lexeme.substring(1, 3), radix: 16),
      int.parse(token.lexeme.substring(3, 5), radix: 16),
      int.parse(token.lexeme.substring(5, 7), radix: 16),
    );
  }

  Map<String, WidgetComponent> parseScaffoldChildren() {
    final children = <String, WidgetComponent>{};

    while (peek().type != TokenType.rbrace) {
      final child = parseScaffoldChild();
      children[child.key] = child.value;
    }

    return children;
  }

  MapEntry<String, WidgetComponent> parseScaffoldChild() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.appBar:
        return MapEntry('appBar', parseAppBarComponent());
      case TokenType.body:
        return MapEntry('body', parseBodyComponent());
      default:
        throw Exception('Expected scaffold child, got ${token.lexeme}');
    }
  }

  AppBarComponent parseAppBarComponent() {
    expect(TokenType.lbrace);

    // Parse dos atributos
    final attributes = parseAppBarAttributes();

    // Verifica se o próximo token é uma abertura de chaves
    // if (getNextToken().type != TokenType.lbrace) {
    //   throw Exception("Expected '{' after appbar attributes");
    // }

    // Parse dos filhos
    // final children = parseAppBarChildren();

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbrace) {
      throw Exception("Expected '}' after appbar children");
    }

    // Retorna o componente Scaffold
    return AppBarComponent(
      title: attributes['title'],
      backgroundColor: Color(0, 0, 0),
      // backgroundColor: attributes['backgroundColor']! as Color,
    );
  }

  BodyComponent parseBodyComponent() {
    expect(TokenType.lbrace);

    // Verifica se o próximo token é uma abertura de chaves
    // if (getNextToken().type != TokenType.lbrace) {
    //   throw Exception("Expected '{' after body");
    // }

    // Parse dos filhos
    final children = parseBodyChildren();

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbrace) {
      throw Exception("Expected '}' after body children");
    }

    // Retorna o componente Scaffold
    return BodyComponent(
      children,
    );
  }

  List<WidgetComponent> parseBodyChildren() {
    final children = <WidgetComponent>[];

    while (peek().type != TokenType.rbrace) {
      children.add(parseBodyChild());
    }

    return children;
  }

  WidgetComponent parseBodyChild() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.column:
        return parseColumnComponent();
      default:
        throw Exception('Expected body child, got ${token.lexeme}');
    }
  }

  Map<String, dynamic> parseAppBarAttributes() {
    final attributes = <String, dynamic>{};

    while (peek().type != TokenType.lbrace) {
      final attribute = parseAttribute();
      attributes[attribute.name] = attribute.value;
      if (peek().type == TokenType.rbrace) {
        break;
      }
    }

    return attributes;
  }

  Map<String, WidgetComponent> parseAppBarChildren() {
    final children = <String, WidgetComponent>{};

    while (peek().type != TokenType.rbrace) {
      final child = parseAppBarChild();
      children[child.key] = child.value;
    }

    return children;
  }

  MapEntry<String, WidgetComponent> parseAppBarChild() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.title:
        return MapEntry('title', parseTitleComponent() as WidgetComponent);
      case TokenType.backgroundColor:
        return MapEntry('backgroundColor', parseBackgroundColorComponent());
      default:
        throw Exception('Expected appbar child, got ${token.lexeme}');
    }
  }

  WidgetComponent parseBackgroundColorComponent() {
    expect(TokenType.backgroundColor);

    // Parse dos atributos
    final attributes = parseBackgroundColorAttributes();

    // Verifica se o próximo token é uma abertura de chaves
    if (getNextToken().type != TokenType.lbrace) {
      throw Exception("Expected '{' after backgroundcolor attributes");
    }

    // Parse dos filhos
    final children = parseBackgroundColorChildren();

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbrace) {
      throw Exception("Expected '}' after backgroundcolor children");
    }

    // Retorna o componente Scaffold
    return WidgetComponent();
  }

  Map<String, dynamic> parseBackgroundColorAttributes() {
    final attributes = <String, dynamic>{};

    while (peek().type != TokenType.lbrace) {
      final attribute = parseAttribute();
      attributes[attribute.name] = attribute.value;
    }

    return attributes;
  }

  Map<String, WidgetComponent> parseBackgroundColorChildren() {
    final children = <String, WidgetComponent>{};

    while (peek().type != TokenType.rbrace) {
      final child = parseBackgroundColorChild();
      children[child.key] = child.value;
    }

    return children;
  }

  MapEntry<String, WidgetComponent> parseBackgroundColorChild() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.color:
        return MapEntry('color', parseColorComponent());
      default:
        throw Exception('Expected backgroundcolor child, got ${token.lexeme}');
    }
  }

  WidgetComponent parseColorComponent() {
    expect(TokenType.color);

    // Parse dos atributos
    final attributes = parseColorAttributes();

    // Verifica se o próximo token é uma abertura de chaves
    if (getNextToken().type != TokenType.lbrace) {
      throw Exception("Expected '{' after color attributes");
    }

    // Parse dos filhos
    final children = parseColorChildren();

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbrace) {
      throw Exception("Expected '}' after color children");
    }

    // Retorna o componente Scaffold
    return WidgetComponent();
  }

  Map<String, dynamic> parseColorAttributes() {
    final attributes = <String, dynamic>{};

    while (peek().type != TokenType.lbrace) {
      final attribute = parseAttribute();
      attributes[attribute.name] = attribute.value;
    }

    return attributes;
  }

  Map<String, WidgetComponent> parseColorChildren() {
    final children = <String, WidgetComponent>{};

    while (peek().type != TokenType.rbrace) {
      final child = parseColorChild();
      children[child.key] = child.value;
    }

    return children;
  }

  MapEntry<String, WidgetComponent> parseColorChild() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.hex:
        return MapEntry('hex', parseHexComponent());
      default:
        throw Exception('Expected color child, got ${token.lexeme}');
    }
  }

  WidgetComponent parseHexComponent() {
    expect(TokenType.hex);

    // Parse dos atributos
    final attributes = parseHexAttributes();

    // Verifica se o próximo token é uma abertura de chaves
    if (getNextToken().type != TokenType.lbrace) {
      throw Exception("Expected '{' after hex attributes");
    }

    // Parse dos filhos
    final children = parseHexChildren();

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbrace) {
      throw Exception("Expected '}' after hex children");
    }

    // Retorna o componente Scaffold
    return WidgetComponent();
  }

  Map<String, dynamic> parseHexAttributes() {
    final attributes = <String, dynamic>{};

    while (peek().type != TokenType.lbrace) {
      final attribute = parseAttribute();
      attributes[attribute.name] = attribute.value;
    }

    return attributes;
  }

  Map<String, WidgetComponent> parseHexChildren() {
    final children = <String, WidgetComponent>{};

    while (peek().type != TokenType.rbrace) {
      final child = parseHexChild();
      children[child.key] = child.value;
    }

    return children;
  }

  MapEntry<String, WidgetComponent> parseHexChild() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.value:
        return MapEntry('value', parseValueComponent());
      default:
        throw Exception('Expected hex child, got ${token.lexeme}');
    }
  }

  WidgetComponent parseValueComponent() {
    expect(TokenType.value);

    // Parse dos atributos
    final attributes = parseValueAttributes();

    // Verifica se o próximo token é uma abertura de chaves
    if (getNextToken().type != TokenType.lbrace) {
      throw Exception("Expected '{' after value attributes");
    }

    // Parse dos filhos
    final children = parseValueChildren();

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbrace) {
      throw Exception("Expected '}' after value children");
    }

    // Retorna o componente Scaffold
    return WidgetComponent();
  }

  Map<String, dynamic> parseValueAttributes() {
    final attributes = <String, dynamic>{};

    while (peek().type != TokenType.lbrace) {
      final attribute = parseAttribute();
      attributes[attribute.name] = attribute.value;
    }

    return attributes;
  }

  Map<String, WidgetComponent> parseValueChildren() {
    final children = <String, WidgetComponent>{};

    while (peek().type != TokenType.rbrace) {
      final child = parseValueChild();
      children[child.key] = child.value;
    }

    return children;
  }

  MapEntry<String, WidgetComponent> parseValueChild() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.string:
        return MapEntry('string', parseStringComponent());
      default:
        throw Exception('Expected value child, got ${token.lexeme}');
    }
  }

  WidgetComponent parseStringComponent() {
    expect(TokenType.string);

    // Parse dos atributos
    final attributes = parseStringAttributes();

    // Verifica se o próximo token é uma abertura de chaves
    if (getNextToken().type != TokenType.lbrace) {
      throw Exception("Expected '{' after string attributes");
    }

    // Parse dos filhos
    final children = parseStringChildren();

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbrace) {
      throw Exception("Expected '}' after string children");
    }

    // Retorna o componente Scaffold
    return WidgetComponent();
  }

  Map<String, dynamic> parseStringAttributes() {
    final attributes = <String, dynamic>{};

    while (peek().type != TokenType.lbrace) {
      final attribute = parseAttribute();
      attributes[attribute.name] = attribute.value;
    }

    return attributes;
  }

  Map<String, WidgetComponent> parseStringChildren() {
    final children = <String, WidgetComponent>{};

    while (peek().type != TokenType.rbrace) {
      final child = parseStringChild();
      children[child.key] = child.value;
    }

    return children;
  }

  MapEntry<String, WidgetComponent> parseStringChild() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.value:
        return MapEntry('value', parseValueComponent());
      default:
        throw Exception('Expected string child, got ${token.lexeme}');
    }
  }

  TitleComponent parseTitleComponent() {
    expect(TokenType.title);

    // Parse dos atributos
    final attributes = parseTitleAttributes();

    // Verifica se o próximo token é uma abertura de chaves
    if (getNextToken().type != TokenType.lbrace) {
      throw Exception("Expected '{' after title attributes");
    }

    // Parse dos filhos
    final children = parseTitleChildren();

    // Verifica se o próximo token é um fechamento de chaves
    if (getNextToken().type != TokenType.rbrace) {
      throw Exception("Expected '}' after title children");
    }

    // Retorna o componente Scaffold
    return TitleComponent(
      attributes['title'],
    );
  }

  Map<String, dynamic> parseTitleAttributes() {
    final attributes = <String, dynamic>{};

    while (peek().type != TokenType.lbrace) {
      final attribute = parseAttribute();
      attributes[attribute.name] = attribute.value;
    }

    return attributes;
  }

  Map<String, WidgetComponent> parseTitleChildren() {
    final children = <String, WidgetComponent>{};

    while (peek().type != TokenType.rbrace) {
      final child = parseTitleChild();
      children[child.key] = child.value;
    }

    return children;
  }

  MapEntry<String, WidgetComponent> parseTitleChild() {
    final token = getNextToken();
    switch (token.type) {
      case TokenType.title:
        return MapEntry('title', parseTitleComponent() as WidgetComponent);
      default:
        throw Exception('Expected title child, got ${token.lexeme}');
    }
  }

  ColumnComponent parseColumnComponent() {
    // Parse dos atributos
    // final attributes = parseColumnAttributes();

    // if (getNextToken().type != TokenType.colon) {
    //   throw Exception("Expected ':' after column attributes");
    // }

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

  String parseIdentifier() {
    final token = expect(TokenType.identifier);
    return token.lexeme;
  }

  double parseNumberLiteral() {
    final token = expect(TokenType.numberLiteral);
    return double.parse(token.lexeme);
  }
}
