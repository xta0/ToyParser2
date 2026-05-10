//
//  Assignment.swift
//  ToyParser
//
//  Created by Tao Xu on 5/3/26.
//

import Foundation

extension Parser {
  // AssignmentExpression
  //   : AdditiveExpression
  //   | LeftHandSideExpression AssignmentOperator AssignmentExpression
  //   ;
  func assignmentExpressionBuilder() throws -> Expression {
    // non-assignment statement
    var left = try additiveExpressionBuilder()
    guard let type = lookahead?.type, isAssignmentOp(type) else {
      return left
    }

    // check the op first
    let operatorToken = try assignmentOperator()

    // left has to be a prim op
    left = try checkValidAssignment(left, operatorToken)

    // right recursion
    return try .assignmentExpression(
      AssignmentExpression(
        operatorValue: operatorToken.value,
        left: left,
        right: assignmentExpressionBuilder()
      )
    )
  }

  // AssignmentOperator
  //   : SIMPLE_ASSIGNMENT
  //   | COMPLEX_ASSIGNMENT
  //   ;
  private func assignmentOperator() throws -> Token {
    if lookahead?.type == .SIMPLE_ASSIGNMENT {
      return try eat(.SIMPLE_ASSIGNMENT)
    }
    return try eat(.COMPLEX_ASSIGNMENT)
  }

  private func isAssignmentOp(_ op: TokenType) -> Bool {
    op == .SIMPLE_ASSIGNMENT || op == .COMPLEX_ASSIGNMENT
  }

  private func checkValidAssignment(_ lhs: Expression, _: Token) throws -> Expression {
    guard case .identifierExpression = lhs else {
      throw ParserError.unexpectedAssignmentOperator
    }
    return lhs
  }
}
