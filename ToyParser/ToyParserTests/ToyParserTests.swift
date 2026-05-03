//
//  ToyParserTests.swift
//  ToyParserTests
//
//  Created by Tao Xu on 1/2/25.
//

import Testing
@testable import ToyParser

struct ToyParserTests {

  @Test func parsesNumericLiteralExpressionStatement() throws {
    let program = try parseProgram("42;")

    #expect(program.body.count == 1)
    let expression = try expressionStatementValue(program.body[0])

    guard case let .numericLiteral(node) = expression else {
      Issue.record("Expected NumericLiteral expression")
      return
    }

    #expect(node.value == 42)
  }

  @Test func parsesDoubleQuotedStringLiteralExpressionStatement() throws {
    let program = try parseProgram(#""hello";"#)

    #expect(program.body.count == 1)
    let expression = try expressionStatementValue(program.body[0])

    guard case let .stringLiteral(node) = expression else {
      Issue.record("Expected StringLiteral expression")
      return
    }

    #expect(node.value == "hello")
  }

  @Test func parsesSingleQuotedStringLiteralExpressionStatement() throws {
    let program = try parseProgram("'hello';")

    #expect(program.body.count == 1)
    let expression = try expressionStatementValue(program.body[0])

    guard case let .stringLiteral(node) = expression else {
      Issue.record("Expected StringLiteral expression")
      return
    }

    #expect(node.value == "hello")
  }

  @Test func parsesEmptyStatement() throws {
    let program = try parseProgram(";")

    #expect(program.body.count == 1)
    guard case .empty = program.body[0] else {
      Issue.record("Expected EmptyStatement")
      return
    }
  }

  @Test func parsesMultipleStatementTypes() throws {
    let program = try parseProgram(#"42; "hello"; ;"#)

    #expect(program.body.count == 3)
    #expect(try numericValue(program.body[0]) == 42)
    #expect(try stringValue(program.body[1]) == "hello")

    guard case .empty = program.body[2] else {
      Issue.record("Expected third statement to be EmptyStatement")
      return
    }
  }

  @Test func parsesEmptyBlockStatement() throws {
    let program = try parseProgram("{}")

    #expect(program.body.count == 1)
    let block = try blockStatement(program.body[0])
    #expect(block.body.isEmpty)
  }

  @Test func parsesBlockStatementBody() throws {
    let program = try parseProgram(#"{ 1; "two"; ; }"#)

    #expect(program.body.count == 1)
    let block = try blockStatement(program.body[0])

    #expect(block.body.count == 3)
    #expect(try numericValue(block.body[0]) == 1)
    #expect(try stringValue(block.body[1]) == "two")

    guard case .empty = block.body[2] else {
      Issue.record("Expected third block statement to be EmptyStatement")
      return
    }
  }

  @Test func parsesNestedBlockStatement() throws {
    let program = try parseProgram("{{ 7; }}")

    #expect(program.body.count == 1)
    let outerBlock = try blockStatement(program.body[0])
    #expect(outerBlock.body.count == 1)

    let innerBlock = try blockStatement(outerBlock.body[0])
    #expect(innerBlock.body.count == 1)
    #expect(try numericValue(innerBlock.body[0]) == 7)
  }

  @Test func skipsWhitespaceAndComments() throws {
    let program = try parseProgram(
      """

      // leading comment
      1;
      /* block comment */
      "two";
      """
    )

    #expect(program.body.count == 2)
    #expect(try numericValue(program.body[0]) == 1)
    #expect(try stringValue(program.body[1]) == "two")
  }

  @Test func parsesAdditionExpression() throws {
    let program = try parseProgram("1 + 2;")
    let expression = try expressionStatementValue(program.body[0])

    let binary = try binaryExpression(expression)
    #expect(binary.operatorValue == "+")
    #expect(try numericValue(binary.left) == 1)
    #expect(try numericValue(binary.right) == 2)
  }

  @Test func parsesSubtractionExpression() throws {
    let program = try parseProgram("5 - 3;")
    let expression = try expressionStatementValue(program.body[0])

    let binary = try binaryExpression(expression)
    #expect(binary.operatorValue == "-")
    #expect(try numericValue(binary.left) == 5)
    #expect(try numericValue(binary.right) == 3)
  }

  @Test func parsesAdditiveExpressionLeftAssociatively() throws {
    let program = try parseProgram("1 + 2 - 3;")
    let expression = try expressionStatementValue(program.body[0])

    let root = try binaryExpression(expression)
    #expect(root.operatorValue == "-")
    #expect(try numericValue(root.right) == 3)

    let left = try binaryExpression(root.left)
    #expect(left.operatorValue == "+")
    #expect(try numericValue(left.left) == 1)
    #expect(try numericValue(left.right) == 2)
  }

  @Test func parseFailsForMissingSemicolon() throws {
    let parser = Parser()

    let program = try parser.parse("42")

    #expect(program == nil)
    #expect(parser.results.contains("Unexpected end of input"))
  }

  @Test func parseFailsForUnknownToken() throws {
    let parser = Parser()

    let program = try parser.parse("@;")

    #expect(program == nil)
    #expect(parser.results.contains("Unexpected token"))
  }
}

private func parseProgram(_ input: String) throws -> Program {
  let parser = Parser()
  let program = try parser.parse(input)
  return try #require(program)
}

private func expressionStatementValue(_ statement: Statement) throws -> Expression {
  guard case let .expression(expressionStatement) = statement else {
    Issue.record("Expected ExpressionStatement")
    throw TestFailure()
  }

  return expressionStatement.value
}

private func blockStatement(_ statement: Statement) throws -> BlockStatement {
  guard case let .block(blockStatement) = statement else {
    Issue.record("Expected BlockStatement")
    throw TestFailure()
  }

  return blockStatement
}

private func binaryExpression(_ expression: Expression) throws -> BinaryExpression {
  guard case let .binaryExpression(binaryExpression) = expression else {
    Issue.record("Expected BinaryExpression")
    throw TestFailure()
  }

  return binaryExpression
}

private func numericValue(_ statement: Statement) throws -> Double {
  try numericValue(expressionStatementValue(statement))
}

private func numericValue(_ expression: Expression) throws -> Double {
  guard case let .numericLiteral(node) = expression else {
    Issue.record("Expected NumericLiteral")
    throw TestFailure()
  }

  return node.value
}

private func stringValue(_ statement: Statement) throws -> String {
  let expression = try expressionStatementValue(statement)

  guard case let .stringLiteral(node) = expression else {
    Issue.record("Expected StringLiteral")
    throw TestFailure()
  }

  return node.value
}

private struct TestFailure: Error {}
