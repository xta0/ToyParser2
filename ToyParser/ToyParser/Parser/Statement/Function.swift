//
//  Function.swift
//  ToyParser
//
//  Created by Tao Xu on 5/10/26.
//

extension Parser {
  // FunctionDeclaration
  //   : KEYWORD("def") Identifier LEFT_BRACE FormalParameterList? RIGHT_BRACE BlockStatement
  //   ;
  //
  // Examples:
  // `def noop() {}`
  // `def add(x, y) { return x + y; }`
  func functionDeclarationBuilder() throws -> FunctionDeclarationStatement {
    try self.eat(.KEYWORD(keyword: "def"))
    let exp = try self.identifierBuilder()
    guard case let .identifierExpression(funcName) = exp else {
      throw ParserError.unexpectedToken(actual: lookahead?.type ?? .UNKNOWN, expected: .IDENTIFIER)
    }
    try self.eat(.LEFT_BRACE)

    let params: [String]
    if self.lookahead?.type != .RIGHT_BRACE {
      params = try self.formalParameterListBuilder()
    } else {
      params = []
    }
    try self.eat(.RIGHT_BRACE)
    let body = try self.blockStatementBuilder()
    return FunctionDeclarationStatement(name: funcName.value, params: params, body: body)
  }

  // ReturnStatement
  //   : KEYWORD("return") Expression? SEMICOLON
  //   ;
  //
  // Examples:
  // `return;`
  // `return x + 1;`
  func returnStatementBuilder() throws -> ReturnStatement {
    try self.eat(.KEYWORD(keyword: "return"))
    if self.lookahead?.type == .SEMICOLON {
      try self.eat(.SEMICOLON)
      return ReturnStatement(value: nil)
    }
    let exp = try self.expressionBuilder()
    try self.eat(.SEMICOLON)
    return ReturnStatement(value: exp)
  }

  // FormalParameterList
  //   : Identifier
  //   | FormalParameterList COMMA Identifier
  //   ;
  //
  // Examples:
  // `x`
  // `x, y, z`
  private func formalParameterListBuilder() throws -> [String] {
    var params: [String] = []
    let exp = try self.identifierBuilder()
    if case let .identifierExpression(param) = exp {
      params.append(param.value)
    }
    while self.lookahead?.type == .COMMA {
      try self.eat(.COMMA)
      let exp = try self.identifierBuilder()
      if case let .identifierExpression(param) = exp {
        params.append(param.value)
      }
    }
    return params
  }
}
