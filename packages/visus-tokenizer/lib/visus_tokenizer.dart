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
  numberLiteral,
  error,
  eof,
  char,
  column,
  title,
  backgroundColor,
  hex,
  value,

  vif,
  vwhile,
  vprint,

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
