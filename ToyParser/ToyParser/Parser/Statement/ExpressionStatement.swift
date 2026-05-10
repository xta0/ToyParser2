//
//  ExpressionStatement.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

extension Parser {
  // ExpressionStatement
  //   : Expression SEMICOLON
  //   ;
  func expressionStatementBuilder() throws -> ExpressionStatement {
    let expr = try expressionBuilder()
    try eat(.SEMICOLON)
    return ExpressionStatement(value: expr)
  }
}
