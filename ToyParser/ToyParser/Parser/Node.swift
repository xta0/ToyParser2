//
//  AST.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

import Foundation

/**
 ASTNode
 │
 ├── Program
 │
 ├── Statement
 │     ├── EmptyStatement
 │     ├── BlockStatement
 │     └── ExpressionStatement
 │
 ├── Expression
 │     ├── NumericLiteral
 │     └── StringLiteral
 */

protocol ASTNode: Encodable {
  var type: String { get }
}

// MARK: Literal Expression

struct NumericLiteral: ASTNode {
  let type = "NumericLiteral"
  let value: Double
}

struct StringLiteral: ASTNode {
  let type = "StringLiteral"
  let value: String
}

// MARK: Math Expression

struct BinaryExpression: ASTNode {
  let type = "BinaryExpression"
  let operatorValue: String
  let left: Expression
  let right: Expression
}

indirect enum Expression: ASTNode {
  var type: String {
    switch self {
    case let .numericLiteral(num):
      return num.type
    case let .stringLiteral(str):
      return str.type
    case let .binaryExpression(exp):
      return exp.type
    }
  }

  case numericLiteral(NumericLiteral)
  case stringLiteral(StringLiteral)
  case binaryExpression(BinaryExpression)
}

extension Expression: Encodable {
  func encode(to encoder: Encoder) throws {
      switch self {
      case .numericLiteral(let node):
          try node.encode(to: encoder)
      case .stringLiteral(let node):
          try node.encode(to: encoder)
      case .binaryExpression(let node):
        try node.encode(to: encoder)
      }
  }
}

struct EmptyStatement: ASTNode {
  let type = "EmptyStatement"
}

struct BlockStatement: ASTNode {
  let type = "BlockStatement"
  let body: [Statement]
}

struct ExpressionStatement: ASTNode {
  let type = "ExpressionStatement"
  let value: Expression
}

enum Statement: ASTNode {
  var type: String {
    switch self {
    case let .empty(es): return es.type
    case let .block(bs): return bs.type
    case let .expression(exp): return exp.type
    }
  }

  case empty(EmptyStatement)
  case block(BlockStatement)
  case expression(ExpressionStatement)
}

struct Program: ASTNode {
  let type = "Program"
  let body: [Statement]
}

// MARK: DEBUG

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

// MARK: Codable

extension Statement: Encodable {
  func encode(to encoder: Encoder) throws {
      switch self {
      case .empty(let node):
          try node.encode(to: encoder)
      case .block(let node):
          try node.encode(to: encoder)
      case .expression(let node):
          try node.encode(to: encoder)
      }
  }
}
