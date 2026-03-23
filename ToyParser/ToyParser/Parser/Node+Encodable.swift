//
//  Node+Encodable.swift
//  ToyParser
//
//  Created by Tao Xu on 3/21/26.
//

import Foundation

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
