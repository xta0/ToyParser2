//
//  Expression.swift
//  ToyParser
//
//  Created by Tao Xu on 5/3/26.
//

import Foundation

extension Parser {
  // Expression
  //   : AssignmentExpression
  //   ;
  func expressionBuilder() throws -> Expression {
    // take the lowest precedent experssion
    try assignmentExpressionBuilder()
  }
}
