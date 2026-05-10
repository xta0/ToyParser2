//
//  Variable.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

extension Parser {
  // VariableStatement
  //   : KEYWORD("let") VariableDeclarationList SEMICOLON
  //   ;
  func variableStatementBuilder() throws -> VariableStatement {
    try eat(.KEYWORD(keyword: "let"))
    let declarations: [VariableDeclaration] = try variableDeclarationListBuilder()
    try eat(.SEMICOLON)
    return VariableStatement(declarations: declarations)
  }

  // VariableDeclarationList
  //   : VariableDeclaration
  //   | VariableDeclarationList ',' VariableDeclaration
  //   ;
  func variableDeclarationListBuilder() throws -> [VariableDeclaration] {
    var declarations: [VariableDeclaration] = [try variableDeclarationBuilder()]
    while lookahead?.type == .COMMA {
      try eat(.COMMA)
      declarations.append(try variableDeclarationBuilder())
    }
    return declarations
  }

  // VariableDeclaration
  //   : Identifier VariableInitializer?
  //   ;
  func variableDeclarationBuilder() throws -> VariableDeclaration {
    let varName = try identifierBuilder()

    var initializer: Expression?
    if lookahead?.type != .SEMICOLON && lookahead?.type != .COMMA {
      initializer = try variableInitializerBuilder()
    }
    return VariableDeclaration(id: varName.value, initializer: initializer)
  }

  // VariableInitializer
  //   : SIMPLE_ASSIGNMENT AssignmentExpression
  //   ;
  func variableInitializerBuilder() throws -> Expression {
    try eat(.SIMPLE_ASSIGNMENT)
    return try assignmentExpressionBuilder()
  }
}
