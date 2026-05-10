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

  @Test func parsesVariableStatementWithInitializer() throws {
    let program = try parseProgram("let x = 1;")

    #expect(program.body.count == 1)
    let variable = try variableStatement(program.body[0])

    #expect(variable.declarations.count == 1)
    let declaration = variable.declarations[0]
    #expect(declaration.id == "x")
    #expect(try numericValue(#require(declaration.initializer)) == 1)
  }

  @Test func parsesVariableStatementWithoutInitializer() throws {
    let program = try parseProgram("let x;")

    #expect(program.body.count == 1)
    let variable = try variableStatement(program.body[0])

    #expect(variable.declarations.count == 1)
    let declaration = variable.declarations[0]
    #expect(declaration.id == "x")
    #expect(declaration.initializer == nil)
  }

  @Test func parsesVariableStatementWithMultipleDeclarations() throws {
    let program = try parseProgram("let x = 1, y = 2;")

    #expect(program.body.count == 1)
    let variable = try variableStatement(program.body[0])

    #expect(variable.declarations.count == 2)
    #expect(variable.declarations[0].id == "x")
    #expect(try numericValue(#require(variable.declarations[0].initializer)) == 1)
    #expect(variable.declarations[1].id == "y")
    #expect(try numericValue(#require(variable.declarations[1].initializer)) == 2)
  }

  @Test func parsesVariableStatementWithAssignmentInitializer() throws {
    let program = try parseProgram("let foo = bar = 42;")

    #expect(program.body.count == 1)
    let variable = try variableStatement(program.body[0])

    #expect(variable.declarations.count == 1)
    let declaration = variable.declarations[0]
    #expect(declaration.id == "foo")

    let initializer = try assignmentExpression(#require(declaration.initializer))
    #expect(initializer.operatorValue == "=")
    #expect(try identifierValue(initializer.left) == "bar")
    #expect(try numericValue(initializer.right) == 42)
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

  @Test func parsesMultiplicationExpression() throws {
    let program = try parseProgram("2 * 3;")
    let expression = try expressionStatementValue(program.body[0])

    let binary = try binaryExpression(expression)
    #expect(binary.operatorValue == "*")
    #expect(try numericValue(binary.left) == 2)
    #expect(try numericValue(binary.right) == 3)
  }

  @Test func parsesDivisionExpression() throws {
    let program = try parseProgram("8 / 4;")
    let expression = try expressionStatementValue(program.body[0])

    let binary = try binaryExpression(expression)
    #expect(binary.operatorValue == "/")
    #expect(try numericValue(binary.left) == 8)
    #expect(try numericValue(binary.right) == 4)
  }

  @Test func parsesMultiplicativeExpressionLeftAssociatively() throws {
    let program = try parseProgram("8 / 4 * 2;")
    let expression = try expressionStatementValue(program.body[0])

    let root = try binaryExpression(expression)
    #expect(root.operatorValue == "*")
    #expect(try numericValue(root.right) == 2)

    let left = try binaryExpression(root.left)
    #expect(left.operatorValue == "/")
    #expect(try numericValue(left.left) == 8)
    #expect(try numericValue(left.right) == 4)
  }

  @Test func parsesMultiplicativeExpressionBeforeAdditiveExpression() throws {
    let program = try parseProgram("1 + 2 * 3;")
    let expression = try expressionStatementValue(program.body[0])

    let root = try binaryExpression(expression)
    #expect(root.operatorValue == "+")
    #expect(try numericValue(root.left) == 1)

    let right = try binaryExpression(root.right)
    #expect(right.operatorValue == "*")
    #expect(try numericValue(right.left) == 2)
    #expect(try numericValue(right.right) == 3)
  }

  @Test func parsesParenthesizedExpressionBeforeMultiplication() throws {
    let program = try parseProgram("(1 + 2) * 3;")
    let expression = try expressionStatementValue(program.body[0])

    let root = try binaryExpression(expression)
    #expect(root.operatorValue == "*")
    #expect(try numericValue(root.right) == 3)

    let left = try binaryExpression(root.left)
    #expect(left.operatorValue == "+")
    #expect(try numericValue(left.left) == 1)
    #expect(try numericValue(left.right) == 2)
  }

  @Test func parsesSimpleAssignmentExpression() throws {
    let program = try parseProgram("x = 1;")
    let expression = try expressionStatementValue(program.body[0])

    let assignment = try assignmentExpression(expression)
    #expect(assignment.operatorValue == "=")
    #expect(try identifierValue(assignment.left) == "x")
    #expect(try numericValue(assignment.right) == 1)
  }

  @Test func parsesComplexAssignmentOperators() throws {
    let cases: [(source: String, operatorValue: String)] = [
      ("x += 1;", "+="),
      ("x -= 1;", "-="),
      ("x *= 1;", "*="),
      ("x /= 1;", "/="),
    ]

    for testCase in cases {
      let program = try parseProgram(testCase.source)
      let expression = try expressionStatementValue(program.body[0])

      let assignment = try assignmentExpression(expression)
      #expect(assignment.operatorValue == testCase.operatorValue)
      #expect(try identifierValue(assignment.left) == "x")
      #expect(try numericValue(assignment.right) == 1)
    }
  }

  @Test func parsesAssignmentRightAssociatively() throws {
    let program = try parseProgram("x = y = 1;")
    let expression = try expressionStatementValue(program.body[0])

    let root = try assignmentExpression(expression)
    #expect(root.operatorValue == "=")
    #expect(try identifierValue(root.left) == "x")

    let right = try assignmentExpression(root.right)
    #expect(right.operatorValue == "=")
    #expect(try identifierValue(right.left) == "y")
    #expect(try numericValue(right.right) == 1)
  }

  @Test func parsesAssignmentAfterAdditiveExpressionOnRightSide() throws {
    let program = try parseProgram("x = 1 + 2 * 3;")
    let expression = try expressionStatementValue(program.body[0])

    let assignment = try assignmentExpression(expression)
    #expect(assignment.operatorValue == "=")
    #expect(try identifierValue(assignment.left) == "x")

    let right = try binaryExpression(assignment.right)
    #expect(right.operatorValue == "+")
    #expect(try numericValue(right.left) == 1)

    let multiplied = try binaryExpression(right.right)
    #expect(multiplied.operatorValue == "*")
    #expect(try numericValue(multiplied.left) == 2)
    #expect(try numericValue(multiplied.right) == 3)
  }

  @Test func parseFailsForInvalidAssignmentTarget() throws {
    let parser = Parser()

    let program = try parser.parse("x + y = 1;")

    #expect(program == nil)
    #expect(parser.results.contains("Unexpected assignment operator"))
  }

  @Test func printsAdditiveExpressionTree() throws {
    let parser = Parser()
    let program = try #require(try parser.parse("1 + 2 - 3;"))

    let expectedTree = """
    Program
    └─ ExpressionStatement
       └─ BinaryExpression (-)
          ├─ BinaryExpression (+)
          │  ├─ NumericLiteral 1
          │  └─ NumericLiteral 2
          └─ NumericLiteral 3
    """

    #expect(program.treeDescription == expectedTree)
    #expect(parser.results == expectedTree)
  }

  @Test func printsPrecedenceInExpressionTree() throws {
    let program = try parseProgram("1 + 2 * 3;")

    let expectedTree = """
    Program
    └─ ExpressionStatement
       └─ BinaryExpression (+)
          ├─ NumericLiteral 1
          └─ BinaryExpression (*)
             ├─ NumericLiteral 2
             └─ NumericLiteral 3
    """

    #expect(program.treeDescription == expectedTree)
  }

  @Test func printsParenthesizedPrecedenceInExpressionTree() throws {
    let program = try parseProgram("(1 + 2) * 3;")

    let expectedTree = """
    Program
    └─ ExpressionStatement
       └─ BinaryExpression (*)
          ├─ BinaryExpression (+)
          │  ├─ NumericLiteral 1
          │  └─ NumericLiteral 2
          └─ NumericLiteral 3
    """

    #expect(program.treeDescription == expectedTree)
  }

  @Test func printsVariableStatementTree() throws {
    let program = try parseProgram("let x = 1, y;")

    let expectedTree = """
    Program
    └─ VariableStatement
       ├─ VariableDeclaration x
       │  └─ NumericLiteral 1
       └─ VariableDeclaration y
    """

    #expect(program.treeDescription == expectedTree)
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

  @Test func parseFailsForMissingClosingParenthesis() throws {
    let parser = Parser()

    let program = try parser.parse("(1 + 2;")

    #expect(program == nil)
    #expect(parser.results.contains("Unexpected token"))
    #expect(parser.results.contains("RIGHT_BRACE"))
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

private func variableStatement(_ statement: Statement) throws -> VariableStatement {
  guard case let .variable(variableStatement) = statement else {
    Issue.record("Expected VariableStatement")
    throw TestFailure()
  }

  return variableStatement
}

private func binaryExpression(_ expression: Expression) throws -> BinaryExpression {
  guard case let .binaryExpression(binaryExpression) = expression else {
    Issue.record("Expected BinaryExpression")
    throw TestFailure()
  }

  return binaryExpression
}

private func assignmentExpression(_ expression: Expression) throws -> AssignmentExpression {
  guard case let .assignmentExpression(assignmentExpression) = expression else {
    Issue.record("Expected AssignmentExpression")
    throw TestFailure()
  }

  return assignmentExpression
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

private func identifierValue(_ expression: Expression) throws -> String {
  guard case let .identifierExpression(node) = expression else {
    Issue.record("Expected IdentifierExpression")
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
