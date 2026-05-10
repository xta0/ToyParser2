//
//  Parser.swift
//  ToyParser
//
//  Created by Tao Xu on 1/2/25.
//

import Foundation

enum ParserError: Error, CustomStringConvertible {
  case unexpectedEndOfInput(expected: TokenType)
  case unexpectedToken(actual: TokenType, expected: TokenType)
  case unexpectedLiteralProduction
  case unexpectedBinaryOperator(actual: TokenType)
  case unexpectedAssignmentOperator
  case unexpectedKeyword(keyword: String)

  var description: String {
    switch self {
    case let .unexpectedEndOfInput(expected):
      return "Unexpected end of input, expected: \(expected)"
    case let .unexpectedToken(actual, expected):
      return "Unexpected token: \(actual), expected: \(expected)"
    case .unexpectedLiteralProduction:
      return "Literal: unexpected literal production"
    case let .unexpectedBinaryOperator(actual: actual):
      return "Unexpected binary operator: \(actual)"
    case .unexpectedAssignmentOperator:
      return "Unexpected assignment operator"
    case let .unexpectedKeyword(keyword: keyword):
      return "Unepected keyword: \(keyword)"
    }
  }
}


final class Parser: ObservableObject {
  @Published var results: String = ""
  @Published private(set) var ast: Program?

  private(set) var string: String = ""
  private(set) var lookahead: Token?

  private let tokenizer = Tokenizer()

  init() {}

  @discardableResult
  func parse(_ input: String) throws -> Program? {
    string = input
    tokenizer.initialize(input)
    do {
      lookahead = try tokenizer.getNextToken()
      let ast = try programBuilder()
      self.ast = ast
      results = ast.treeDescription
      return ast
    } catch {
      ast = nil
      results = "\(error)"
    }
    return nil
  }

  @discardableResult
  func eat(_ tokenType: TokenType) throws -> Token {
    guard let token = lookahead else {
      throw ParserError.unexpectedEndOfInput(expected: tokenType)
    }

    guard token.type == tokenType else {
      throw ParserError.unexpectedToken(actual: token.type, expected: tokenType)
    }
    print("[Parser] Eat \(tokenType)")
    lookahead = try tokenizer.getNextToken()
    return token
  }
}
