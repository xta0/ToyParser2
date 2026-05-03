//
//  parser.swift
//  ToyParser
//
//  Created by Tao Xu on 1/2/25.
//

import Foundation

final class Parser: ObservableObject {
  @Published var results: String = ""

  private var string: String = ""
  private var lookahead: Token?

  private let tokenizer = Tokenizer()

  init() {}

  @discardableResult
  func parse(_ input: String) throws  -> Program? {
    self.string = input
    self.tokenizer.initialize(input)
    do {
      self.lookahead = try self.tokenizer.getNextToken()
      let ast = try self.program()
      self.results = ast.description
      return ast
    } catch {
      self.results = "\(error)"
    }
    return nil
  }

  @discardableResult
  private func eat(_ tokenType: TokenType) throws -> Token {
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

// Left Recursive Descent Parsing
extension Parser {
  // Program
  //   : StatementList
  //   ;
  private func program() throws -> Program {
    Program(body: try statementList())
  }

  // StatementList
  //   : Statement
  //   | StatementList Statement
  //   ;
  //
  // A StatementList can be either:
  // 1. A single Statement
  // 2. A StatementList followed by another Statement
  //
  // Left recursive:
  //
  // StatementList → StatementList Statement
  // Statement
  // Statement Statement
  // Statement Statement Statement
  // Statement Statement Statement Statement
  // ...
  //
  // Pasre multiple statements until a stopping token appears
  private func statementList(stopTokenType: TokenType? = nil) throws -> [Statement] {
    let stat = try statement()
    print("[Parser] Add statement to list: [\(stat.type)]")
    var statements: [Statement] = [stat]

    while lookahead != nil && lookahead?.type != stopTokenType {
      let stat = try statement()
      print("[Parser] Add statement to list: [\(stat.type)]")
      statements.append(stat)
    }

    return statements
  }

  // Statement
  //   : ExpressionStatement
  //   | BlockStatement
  //   | EmptyStatement
  //   ;
  private func statement() throws -> Statement {
    guard let lookahead else {
      throw ParserError.unexpectedLiteralProduction
    }

    switch lookahead.type {
    case .SEMICOLON:
      return .empty(try emptyStatement())
    case .LEFT_CURLY_BRACE:
      return .block(try blockStatement())
    default:
      return .expression(try expressionStatement())
    }
  }

  // ExpressionStatement
  //   : Expression ; // expression ends with ";"
  //   ;
  private func expressionStatement() throws -> ExpressionStatement {
    let expr = try expression()
    try eat(.SEMICOLON)
    return ExpressionStatement(value: expr)
  }

  // Expression
  //   : Literal
  //   : Binary Expression
  //   ;
  private func expression() throws -> Expression {
      try additiveExpression()
  }

  // AdditiveExpression
  //   : Literal
  //   | AdditiveExpression ADDITIVE_OPERATOR Literal (left recursive rule)
  //   ;
  //
  // Left recursive:
  //
  // AdditiveExpression → AdditiveExpression ADDITIVE_OPERATOR Literal
  // Literal ADDITIVE_OPERATOR Literal
  // Literal ADDITIVE_OPERATOR Literal ADDITIVE_OPERATOR Literal
  // ...
  private func additiveExpression() throws -> Expression {
    // left: Expression
    // right: Expression
    var left = try literal()
    while (self.lookahead?.type == .ADD) {
      let operatorValue = try eat(.ADD).value
      let right = try literal()
      left = .binaryExpression(
        BinaryExpression(
          operatorValue: operatorValue,
          left: left,
          right: right
        )
      )
    }

    return left
  }

  /// Literal
  ///   : NumericLiteral
  ///   | StringLiteral
  ///   ;
  private func literal() throws -> Expression {
      guard let lookahead else {
          throw ParserError.unexpectedLiteralProduction
      }

      switch lookahead.type {
      case .NUMBER:
          return .numericLiteral(try numericLiteral())
      case .STRING:
          return .stringLiteral(try stringLiteral())
      default:
          throw ParserError.unexpectedLiteralProduction
      }
  }

  /// NumericLiteral
  ///   : NUMBER
  ///   ;
  private func numericLiteral() throws -> NumericLiteral {
      let token = try eat(.NUMBER)
      return NumericLiteral(value: Double(token.value) ?? 0)
  }

  /// StringLiteral
  ///   : STRING
  ///   ;
  private func stringLiteral() throws -> StringLiteral {
      let token = try eat(.STRING)
      return StringLiteral(value: String(token.value.dropFirst().dropLast()))
  }

  // BlockStatement
  //   : { OptBlockStatement }
  //   ;
  private func blockStatement() throws -> BlockStatement {
    try eat(.LEFT_CURLY_BRACE)

    let body: [Statement]
    if lookahead?.type != .RIGHT_CURLY_BRACE {
      // Recursive Parsing (e.g. nested blocks)
      body = try statementList(stopTokenType: .RIGHT_CURLY_BRACE)
    } else {
      body = []
    }

    try eat(.RIGHT_CURLY_BRACE)

    return BlockStatement(body: body)
  }

  // EmptyStatement
  //   : ;
  //   ;
  private func emptyStatement() throws -> EmptyStatement {
    try eat(.SEMICOLON)
    return EmptyStatement()
  }

}
