//
//  Token.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

enum TokenType {
  case SEMICOLON
  case COMMA

  case LEFT_CURLY_BRACE
  case RIGHT_CURLY_BRACE

  case LEFT_BRACE
  case RIGHT_BRACE

  case NUMBER
  case STRING
  
  case BLANK
  case COMMENT
  case COMMENT_BLOCK
  case UNKNOWN

  case ADD
  case MUL

  case IDENTIFIER

  case SIMPLE_ASSIGNMENT
  case COMPLEX_ASSIGNMENT

  case KEYWORD(keyword: String)

  case RELATIONAL
  case EQUALITY
  case LOGICAL_AND
  case LOGICAL_OR

  // unary;
  case UNARY(op: String)

  case UNSUPPORTED
}

extension TokenType: Equatable {
  static func == (lhs: TokenType, rhs: TokenType) -> Bool {
    switch (lhs, rhs) {
    case (.SEMICOLON, .SEMICOLON),
         (.COMMA, .COMMA),
         (.LEFT_CURLY_BRACE, .LEFT_CURLY_BRACE),
         (.RIGHT_CURLY_BRACE, .RIGHT_CURLY_BRACE),
         (.LEFT_BRACE, .LEFT_BRACE),
         (.RIGHT_BRACE, .RIGHT_BRACE),
         (.NUMBER, .NUMBER),
         (.STRING, .STRING),
         (.BLANK, .BLANK),
         (.COMMENT, .COMMENT),
         (.COMMENT_BLOCK, .COMMENT_BLOCK),
         (.UNKNOWN, .UNKNOWN),
         (.ADD, .ADD),
         (.MUL, .MUL),
         (.IDENTIFIER, .IDENTIFIER),
         (.SIMPLE_ASSIGNMENT, .SIMPLE_ASSIGNMENT),
         (.RELATIONAL, .RELATIONAL),
         (.EQUALITY, .EQUALITY),
         (.LOGICAL_AND, .LOGICAL_AND),
         (.LOGICAL_OR, .LOGICAL_OR),
         (.COMPLEX_ASSIGNMENT, .COMPLEX_ASSIGNMENT):
      return true
    case let (.KEYWORD(lhsKeyword), .KEYWORD(rhsKeyword)):
      return lhsKeyword == rhsKeyword
    case let (.UNARY(lhs), .UNARY(rhs)):
      return lhs == rhs
    default:
      return false
    }
  }
}

struct Token {
  let type: TokenType
  let value: String
}

struct TokenSpec {
  let regex: Regex<Substring>
  let type: TokenType
}

extension Token {
  static let specs: [TokenSpec] = [
    TokenSpec(regex: /^\s/, type: .BLANK),
    TokenSpec(regex: /^\/\/.*/, type: .COMMENT),
    TokenSpec(regex: /^\/\*[\s\S]*?\*\//, type: .COMMENT),

    // ;, ,
    TokenSpec(regex: /^;/, type: .SEMICOLON),
    TokenSpec(regex: /^,/, type: .COMMA),

    // {..}, (..)
    TokenSpec(regex: /^\{/, type: .LEFT_CURLY_BRACE),
    TokenSpec(regex: /^\}/, type: .RIGHT_CURLY_BRACE),
    TokenSpec(regex: /^\(/, type: .LEFT_BRACE),
    TokenSpec(regex: /^\)/, type: .RIGHT_BRACE),

    // number:
    TokenSpec(regex: /^\d+/, type: .NUMBER),

    // string:
    TokenSpec(regex: /^"[^"]*"/, type: .STRING),
    TokenSpec(regex: /^'[^']*'/, type: .STRING),

    // relational ops: >, <, >=, <=
    TokenSpec(regex: /^[><]=?/, type: .RELATIONAL),

    // equality ops: ==, !=
    // needs to be above unary and assignment
    TokenSpec(regex: /^==/, type: .EQUALITY),
    TokenSpec(regex: /^!=/, type: .EQUALITY),

    // logical ops: &&, ||
    TokenSpec(regex: /^&&/, type: .LOGICAL_AND),
    TokenSpec(regex: /^\|\|/, type: .LOGICAL_OR),

    // unary ops: !
    TokenSpec(regex: /^!/, type: .UNARY(op: "!")),

    // assignment: =, +=, -=, *=, /=
    TokenSpec(regex: /^[\*\+\-\/]=/, type: .COMPLEX_ASSIGNMENT),
    TokenSpec(regex: /^=/, type: .SIMPLE_ASSIGNMENT),

    // math ops: +, -, *, /
    TokenSpec(regex: /^[+\-]/, type: .ADD),
    TokenSpec(regex: /^[*\/]/, type: .MUL),

    // keywords:
    TokenSpec(regex: /^\blet/, type: .KEYWORD(keyword: "let")),
    TokenSpec(regex: /^\bif/, type: .KEYWORD(keyword: "if")),
    TokenSpec(regex: /^\belse/, type: .KEYWORD(keyword: "else")),
    TokenSpec(regex: /^\btrue/, type: .KEYWORD(keyword: "true")),
    TokenSpec(regex: /^\bfalse/, type: .KEYWORD(keyword: "false")),
    TokenSpec(regex: /^\bnull/, type: .KEYWORD(keyword: "null")),
    TokenSpec(regex: /^\bwhile/, type: .KEYWORD(keyword: "while")),
    TokenSpec(regex: /^\bfor/, type: .KEYWORD(keyword: "for")),
    TokenSpec(regex: /^\bdo/, type: .KEYWORD(keyword: "do")),

    // identifiers (needs to checked after number):
    TokenSpec(regex: /^\w+/, type: .IDENTIFIER),
    
  ]
}

enum LexerError: Error, CustomStringConvertible {
  case unexpectedToken(String)

  var description: String {
    switch self {
    case let .unexpectedToken(token):
      return "Unexpected token: \"\(token)\""
    }
  }
}
