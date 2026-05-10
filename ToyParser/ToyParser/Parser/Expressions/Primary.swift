//
//  Primary.swift
//  ToyParser
//
//  Created by Tao Xu on 5/3/26.
//

import Foundation

extension Parser {
  // PrimaryExpression
  //   : Literal
  //   | ParenthesizedExpression
  //   | Identifier
  //   ;
  func primaryExpressionBuilder() throws -> Expression {
    if isLiteral() {
      return try literalBuilder()
    }
    switch lookahead?.type {
    case .LEFT_BRACE:
      return try parenthesizedExpressionBuilder()
    default:
      return try leftHandSideExpressionBuilder()
    }
  }

  // ParenthesizedExpression
  //   : LEFT_BRACE Expression RIGHT_BRACE
  //   ;
  func parenthesizedExpressionBuilder() throws -> Expression {
    try eat(.LEFT_BRACE)
    let expr = try expressionBuilder()
    try eat(.RIGHT_BRACE)
    return expr
  }
}

// MARK: Identifier

extension Parser {
  // Identifier
  //   : IDENTIFIER
  //   ;
  func identifierBuilder() throws -> IdentifierExpression {
    let name = try eat(.IDENTIFIER).value
    return IdentifierExpression(value: name)
  }

  // LeftHandSideExpression
  //   : Identifier
  //   ;
  func leftHandSideExpressionBuilder() throws -> Expression {
    try .identifierExpression(identifierBuilder())
  }
}

// MARK: Literal

extension Parser {
  // Literal
  //   : NumericLiteral
  //   | StringLiteral
  //   ;
  func literalBuilder() throws -> Expression {
    guard let lookahead else {
      throw ParserError.unexpectedLiteralProduction
    }

    switch lookahead.type {
    case .NUMBER:
      return try .numericLiteral(numericLiteralBuilder())
    case .STRING:
      return try .stringLiteral(stringLiteralBuilder())
    default:
      throw ParserError.unexpectedLiteralProduction
    }
  }

  // NumericLiteral
  //   : NUMBER
  //   ;
  func numericLiteralBuilder() throws -> NumericLiteral {
    let token = try eat(.NUMBER)
    return NumericLiteral(value: Double(token.value) ?? 0)
  }

  // StringLiteral
  //   : STRING
  //   ;
  func stringLiteralBuilder() throws -> StringLiteral {
    let token = try eat(.STRING)
    return StringLiteral(value: String(token.value.dropFirst().dropLast()))
  }

  private func isLiteral() -> Bool {
    lookahead?.type == .NUMBER || lookahead?.type == .STRING
  }
}
