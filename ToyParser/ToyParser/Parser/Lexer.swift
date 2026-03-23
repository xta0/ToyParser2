//
//  Tokenizer+Regex.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

enum TokenType {
    case SEMICOLON
    case LEFT_CURLY_BRACE
    case RIGHT_CURLY_BRACE
    case NUMBER
    case STRING

    case BLANK
    case COMMENT
    case COMMENT_BLOCK
    case UNKNOWN
}

struct Token {
  let type: TokenType
  let value: String
}

struct TokenSpec {
  let regex: Regex<Substring>
  let type: TokenType
}

struct Lexer {
  static let specs: [TokenSpec] = [
    TokenSpec(regex: /^\s/, type: .BLANK),
    TokenSpec(regex: /^\/\/.*/, type: .COMMENT),
    TokenSpec(regex: /^\/\*[\s\S]*?\*\//, type: .COMMENT),

    TokenSpec(regex: /^;/, type: .SEMICOLON),
    TokenSpec(regex: /^\{/, type: .LEFT_CURLY_BRACE),
    TokenSpec(regex: /^\}/, type: .RIGHT_CURLY_BRACE),

    TokenSpec(regex: /^\d+/, type: .NUMBER),
    TokenSpec(regex: /^"[^"]*"/, type: .STRING),
    TokenSpec(regex: /^'[^']*'/, type: .STRING),
  ]
}

enum LexerError: Error, CustomStringConvertible {
    case unexpectedToken(String)

    var description: String {
        switch self {
        case .unexpectedToken(let token):
            return "Unexpected token: \"\(token)\""
        }
    }
}

