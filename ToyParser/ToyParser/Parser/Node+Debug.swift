//
//  Node+Debug.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

import Foundation

// MARK: DEBUG

extension Program {
  var treeDescription: String {
    ASTPrinter().print(self)
  }
}

extension Program: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    do {
      let data = try encoder.encode(self)
      return String(data: data, encoding: .utf8) ?? "{}"
    } catch {
      return #"{"error":"Failed to encode AST"}"#
    }
  }
}

private struct ASTPrinter {
  func print(_ program: Program) -> String {
    var lines = ["Program"]
    appendStatements(program.body, to: &lines, prefix: "")
    return lines.joined(separator: "\n")
  }

  private func appendStatements(_ statements: [Statement], to lines: inout [String], prefix: String) {
    for (index, statement) in statements.enumerated() {
      appendStatement(
        statement,
        to: &lines,
        prefix: prefix,
        isLast: index == statements.count - 1
      )
    }
  }

  private func appendStatement(_ statement: Statement, to lines: inout [String], prefix: String, isLast: Bool) {
    lines.append("\(prefix)\(branch(isLast))\(label(for: statement))")

    switch statement {
    case .empty:
      return
    case let .block(block):
      appendStatements(block.body, to: &lines, prefix: childPrefix(prefix, isLast: isLast))
    case let .expression(expressionStatement):
      appendExpression(
        expressionStatement.value,
        to: &lines,
        prefix: childPrefix(prefix, isLast: isLast),
        isLast: true
      )
    case let .variable(variableStatement):
      appendVariableStatement(
        variableStatement,
        to: &lines,
        prefix: childPrefix(prefix, isLast: isLast)
      )
    }
  }

  private func appendVariableStatement(_ statement: VariableStatement, to lines: inout [String], prefix: String) {
    for (index, declaration) in statement.declarations.enumerated() {
      appendVariableDeclaration(
        declaration,
        to: &lines,
        prefix: prefix,
        isLast: index == statement.declarations.count - 1
      )
    }
  }

  private func appendVariableDeclaration(
    _ declaration: VariableDeclaration,
    to lines: inout [String],
    prefix: String,
    isLast: Bool
  ) {
    lines.append("\(prefix)\(branch(isLast))VariableDeclaration \(declaration.id)")

    guard let initializer = declaration.initializer else {
      return
    }

    appendExpression(
      initializer,
      to: &lines,
      prefix: childPrefix(prefix, isLast: isLast),
      isLast: true
    )
  }

  private func appendExpression(_ expression: Expression, to lines: inout [String], prefix: String, isLast: Bool) {
    lines.append("\(prefix)\(branch(isLast))\(label(for: expression))")

    let left: Expression
    let right: Expression
    switch expression {
    case let .binaryExpression(node):
      left = node.left
      right = node.right
    case let .assignmentExpression(node):
      left = node.left
      right = node.right
    default:
      return
    }

    let nextPrefix = childPrefix(prefix, isLast: isLast)
    appendExpression(left, to: &lines, prefix: nextPrefix, isLast: false)
    appendExpression(right, to: &lines, prefix: nextPrefix, isLast: true)
  }

  private func label(for statement: Statement) -> String {
    switch statement {
    case .empty:
      return "EmptyStatement"
    case .block:
      return "BlockStatement"
    case .expression:
      return "ExpressionStatement"
    case .variable:
      return "VariableStatement"
    }
  }

  private func label(for expression: Expression) -> String {
    switch expression {
    case let .numericLiteral(node):
      return "NumericLiteral \(format(node.value))"
    case let .stringLiteral(node):
      return #"StringLiteral "\#(escaped(node.value))""#
    case let .binaryExpression(node):
      return "BinaryExpression (\(node.operatorValue))"
    case let .assignmentExpression(node):
      return "AssignmentExpression (\(node.operatorValue))"
    case let .identifierExpression(node):
      return "IdentifierExpression \(node.value)"
    }
  }

  private func branch(_ isLast: Bool) -> String {
    isLast ? "└─ " : "├─ "
  }

  private func childPrefix(_ prefix: String, isLast: Bool) -> String {
    prefix + (isLast ? "   " : "│  ")
  }

  private func format(_ value: Double) -> String {
    if value.rounded() == value {
      return String(Int(value))
    }

    return String(value)
  }

  private func escaped(_ value: String) -> String {
    value
      .replacingOccurrences(of: #"\"#, with: #"\\"#)
      .replacingOccurrences(of: #"""#, with: #"\""#)
  }
}
