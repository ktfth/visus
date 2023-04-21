import 'dart:core';

enum TokenType {
  scaffold,
  appBar,
  body,
  button,
  text,
  equal,
  string,
  comma,
  lparen,
  rparen,
  lbrace,
  rbrace,
  dot,
  lbracket,
  rbracket,
  colon,
  semicolon,
  identifier,
  stringLiteral,
  number,
  error,
  eof,

  label,
  padding,
  child,
  color,
  onPressed,
  fontSize,
  fontWeight,
}

class Token {
  final TokenType type;
  final String lexeme;
  final dynamic literal;
  final int line;

  Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString() => "$type $lexeme $literal";
}

class Tokenizer {
  final String source;
  final List<Token> tokens = [];
  final keywords = {
    'label': TokenType.label,
    'button': TokenType.button,
    'padding': TokenType.padding,
    'child': TokenType.child,
    'text': TokenType.text,
    'color': TokenType.color,
    'onPressed': TokenType.onPressed,
    'fontSize': TokenType.fontSize,
    'fontWeight': TokenType.fontWeight,
  };

  int start = 0;
  int current = 0;
  int line = 1;

  Tokenizer(this.source);

  void tokenize() {
    while (!isAtEnd()) {
      start = current;
      scanToken();
    }

    tokens.add(Token(TokenType.eof, "", null, line));
  }

  void scanToken() {
    String c = advance();
    switch (c) {
      case '(':
        addToken(TokenType.lparen);
        break;
      case ')':
        addToken(TokenType.rparen);
        break;
      case '{':
        addToken(TokenType.lbrace);
        break;
      case '}':
        addToken(TokenType.rbrace);
        break;
      case '[':
        addToken(TokenType.rbracket);
        break;
      case ']':
        addToken(TokenType.lbracket);
        break;
      case ',':
        addToken(TokenType.comma);
        break;
      case '.':
        addToken(TokenType.dot);
        break;
      case ';':
        addToken(TokenType.semicolon);
        break;
      case ':':
        addToken(TokenType.colon);
        break;
      case ' ':
        break;
      case '\r':
        break;
      case '\t':
        break;
      case '\n':
        line++;
        break;
      case '"':
        string();
        break;
      default:
        if (isDigit(c)) {
          number();
        } else if (isAlpha(c)) {
          identifier();
        } else {
          throw new Exception("Unexpected character $c.");
        }
        break;
    }
  }

  void identifier() {
    while (isAlphaNumeric(peek())) advance();

    String text = source.substring(start, current);
    TokenType type = TokenType.identifier;
    if (keywords.containsKey(text)) {
      type = keywords[text]!;
    }

    addToken(type);
  }

  void number() {
    while (isDigit(peek())) advance();

    if (peek() == '.' && isDigit(peekNext())) {
      advance();
      while (isDigit(peek())) advance();
    }

    addToken(TokenType.number, double.parse(source.substring(start, current)));
  }

  void string() {
    while (peek() != '"' && !isAtEnd()) {
      if (peek() == '\n') line++;
      advance();
    }

    if (isAtEnd()) {
      throw new Exception("Unterminated string.");
    }

    advance();

    String value = source.substring(start + 1, current - 1);
    addToken(TokenType.stringLiteral, value);
  }

  void addToken(TokenType type, [dynamic literal]) {
    String lexeme = source.substring(start, current);
    tokens.add(Token(type, lexeme, literal, line));
  }

  bool isAtEnd() => current >= source.length;

  String advance() => source[current++];

  bool match(String expected) {
    if (isAtEnd()) return false;
    if (source[current] != expected) return false;

    current++;
    return true;
  }

  String peek() {
    if (isAtEnd()) return '\0';
    return source[current];
  }

  bool isDigit(String str) {
    return int.tryParse(str) != null;
  }

  bool isAlpha(String str) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(str);
  }

  bool isAlphaNumeric(String str) {
    return isAlpha(str) || isDigit(str);
  }

  String peekNext() {
    if (current + 1 >= source.length) {
      return '0';
    } else {
      return source[current + 1];
    }
  }
}
