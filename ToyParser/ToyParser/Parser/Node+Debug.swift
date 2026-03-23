//
//  Node+Debug.swift
//  ToyParser
//
//  Created by Tao Xu on 3/21/26.
//
import Foundation

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
