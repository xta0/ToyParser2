//
//  ToyParserTests.swift
//  ToyParserTests
//
//  Created by Tao Xu on 1/2/25.
//

import Testing
@testable import ToyParser

struct ToyParserTests {

    @Test func literalTest() async throws {
      let literal = "42;"
      let parser = Parser()
      let program = try parser.parse(literal);
      print(program)
    }

}
