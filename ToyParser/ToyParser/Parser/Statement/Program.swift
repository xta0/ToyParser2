//
//  Program.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

extension Parser {
  // Program
  //   : StatementList
  //   ;
  //
  // Examples:
  // `1;`
  // `let x = 1; x + 2;`
  func programBuilder() throws -> Program {
    try Program(body: statementListBuilder())
  }
}
