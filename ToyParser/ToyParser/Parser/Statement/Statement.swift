//
//  Statement.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

extension Parser {
  // StatementList
  //   : Statement
  //   | StatementList Statement
  //   ;
  //
  // A StatementList is parsed with a loop because direct left recursion does
  // not terminate in recursive descent parsers.
  func statementListBuilder(stopTokenType: TokenType? = nil) throws -> [Statement] {
    let stat = try statementBuilder()
    print("[Parser] Add statement to list: [\(stat.type)]")
    var statements: [Statement] = [stat]

    while lookahead != nil, lookahead?.type != stopTokenType {
      let stat = try statementBuilder()
      print("[Parser] Add statement to list: [\(stat.type)]")
      statements.append(stat)
    }

    return statements
  }

  // Statement
  //   : ExpressionStatement
  //   | BlockStatement
  //   | EmptyStatement
  //   | VariableStatement
  //   ;
  func statementBuilder() throws -> Statement {
    guard let lookahead else {
      throw ParserError.unexpectedLiteralProduction
    }

    switch lookahead.type {
    case .SEMICOLON:
      return try .empty(emptyStatementBuilder())
    case .LEFT_CURLY_BRACE:
      return try .block(blockStatementBuilder())
    case let .KEYWORD(kwd):
      if kwd == "let" {
        return try .variable(variableStatementBuilder())
      }
      throw ParserError.unexpectedKeyword(keyword: kwd)
    default:
      return try .expression(expressionStatementBuilder())
    }
  }
}
