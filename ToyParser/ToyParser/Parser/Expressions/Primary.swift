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
  //
  // Examples:
  // `42`
  // `"hello"`
  // `true`
  // `x`
  // `(1 + 2)`
  func primaryExpressionBuilder() throws -> Expression {
    if isLiteral() {
      return try literalBuilder()
    }
    switch lookahead?.type {
    case .LEFT_BRACE:
      return try parenthesizedExpressionBuilder()
    case .IDENTIFIER:
      return try identifierBuilder()
    default:
      return try leftHandSideExpressionBuilder()
    }
  }
}

