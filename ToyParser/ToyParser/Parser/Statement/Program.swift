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
  func programBuilder() throws -> Program {
    try Program(body: statementListBuilder())
  }
}
