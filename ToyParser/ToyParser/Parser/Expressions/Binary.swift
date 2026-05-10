//
//  Binary.swift
//  ToyParser
//
//  Created by Tao Xu on 5/3/26.
//

import Foundation

extension Parser {
  // AdditiveExpression
  //   : MultiplicativeExpression
  //   | AdditiveExpression ADD MultiplicativeExpression
  //   ;
  //
  // Left recursive:
  //
  // AdditiveExpression → AdditiveExpression ADD MultiplicativeExpression
  // MultiplicativeExpression ADD MultiplicativeExpression
  // MultiplicativeExpression ADD MultiplicativeExpression ADD MultiplicativeExpression
  // ...
  func additiveExpressionBuilder() throws -> Expression {
    try binaryExpressionBuilder(.ADD, operand: multiplicativeExpressionBuilder)
  }

  // MultiplicativeExpression
  //   : PrimaryExpression
  //   | MultiplicativeExpression MUL PrimaryExpression
  //   ;
  //
  // Left recursive:
  //
  // MultiplicativeExpression → MultiplicativeExpression MUL PrimaryExpression
  // PrimaryExpression MUL PrimaryExpression
  // PrimaryExpression MUL PrimaryExpression MUL PrimaryExpression
  // ...
  func multiplicativeExpressionBuilder() throws -> Expression {
    try binaryExpressionBuilder(.MUL, operand: primaryExpressionBuilder)
  }
}

extension Parser {
  func binaryExpressionBuilder(_ op: TokenType, operand: () throws -> Expression) throws -> Expression {
    var left = try operand()
    while lookahead?.type == op {
      let operatorValue = try eat(op).value
      let right = try operand()
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
}
