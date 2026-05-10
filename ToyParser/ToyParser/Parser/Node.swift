//
//  Node.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

// ASTNode: concrete nodes that can appear in the AST:
//
// ASTNode
// ├─ Program
// ├─ EmptyStatement
// ├─ BlockStatement
// ├─ ExpressionStatement
// ├─ VariableStatement
// └─ Expression
//    ├─ NumericLiteral
//    ├─ StringLiteral
//    ├─ IdentifierExpression
//    ├─ BinaryExpression
//    └─ AssignmentExpression
//
// Statement is a wrapper over statement node variants, not a concrete ASTNode.
protocol ASTNode {}

// MARK: Literal Expression

struct NumericLiteral: ASTNode, Encodable {
  let type = "NumericLiteral"
  let value: Double
}

struct StringLiteral: ASTNode, Encodable {
  let type = "StringLiteral"
  let value: String
}

// MARK: Expression

// an AST node that produces a value
indirect enum Expression: ASTNode {
  var type: String {
    switch self {
    case let .numericLiteral(num):
      return num.type
    case let .stringLiteral(str):
      return str.type
    case let .binaryExpression(exp):
      return exp.type
    case let .assignmentExpression(exp):
      return exp.type
    case let .identifierExpression(exp):
      return exp.type
    }
  }

  case numericLiteral(NumericLiteral)
  case stringLiteral(StringLiteral)
  case binaryExpression(BinaryExpression)
  case assignmentExpression(AssignmentExpression)
  case identifierExpression(IdentifierExpression)
}

extension Expression: Encodable {
  func encode(to encoder: Encoder) throws {
    switch self {
    case let .numericLiteral(node):
      try node.encode(to: encoder)
    case let .stringLiteral(node):
      try node.encode(to: encoder)
    case let .binaryExpression(node):
      try node.encode(to: encoder)
    case let .assignmentExpression(node):
      try node.encode(to: encoder)
    case let .identifierExpression(node):
      try node.encode(to: encoder)
    }
  }
}

// MARK: Binary Expression

// left: exp
// right: exp

struct BinaryExpression: ASTNode, Encodable {
  let type = "BinaryExpression"
  let operatorValue: String
  let left: Expression
  let right: Expression
}

// MARK: Assignment Expression

struct AssignmentExpression: ASTNode, Encodable {
  let type = "AssignmentExpression"
  let operatorValue: String
  let left: Expression
  let right: Expression
}

// MARK: Identifier Expression

struct IdentifierExpression: ASTNode, Encodable {
  let type = "IdentifierExpression"
  let value: String
}

// MARK: Declaration

struct VariableDeclaration: ASTNode, Encodable {
  let type = "VariableDeclaration"
  let id: String
  let initializer: Expression?
}

// MARK: Statements

enum Statement: Encodable {
  var type: String {
    switch self {
    case let .empty(es): return es.type
    case let .block(bs): return bs.type
    case let .expression(exps): return exps.type
    case let .variable(vs): return vs.type
    }
  }

  case empty(EmptyStatement)
  case block(BlockStatement)
  case expression(ExpressionStatement)
  case variable(VariableStatement)
}


struct EmptyStatement: ASTNode, Encodable {
  let type = "EmptyStatement"
}

struct BlockStatement: ASTNode, Encodable {
  let type = "BlockStatement"
  let body: [Statement]
}

struct ExpressionStatement: ASTNode, Encodable {
  let type = "ExpressionStatement"
  let value: Expression
}

struct VariableStatement: ASTNode, Encodable {
  let type = "VariableStatement"
  let declarations: [VariableDeclaration]
}

// MARK: Program

struct Program: ASTNode, Encodable {
  let type = "Program"
  let body: [Statement]
}
