//
//  tokenizer.swift
//  ToyParser
//
//  Created by Tao Xu on 1/2/25.
//

import Foundation

final class Tokenizer {
  private var input: String = "";
  private var cursor: String.Index!

  init () {}

  func initialize(_ input: String) {
    self.input = input
    self.cursor = input.startIndex
  }

  func isEOF() -> Bool {
    return cursor == input.endIndex
  }

  func hasMoreTokens() -> Bool {
    return cursor < input.endIndex
  }

  // Lazy generation: we don't tokenize the input at once
  func getNextToken() throws(LexerError) -> Token? {
    print("getNextToken()")
    guard hasMoreTokens() else {
      print("Error: No more tokens!")
      return nil
    }

    let remaining = String(input[cursor...])

    // match the next token
    for spec in Lexer.specs {
      if let tokenValue = match(spec.regex, in: remaining) {
        // advance the curor
        cursor = self.input.index(cursor, offsetBy: tokenValue.count)

        print("[Tokenizer] matched: \(tokenValue)")

        // skip comments, linebreaks, etc
        if spec.type == .BLANK || spec.type == .COMMENT || spec.type == .COMMENT_BLOCK {
          print("[Tokenizer] skip the matched token: \(spec.type)")
          return try getNextToken()
        }

        return Token(
          type: spec.type,
          value: tokenValue
        )
      }
    }
    print("Error: can match the next token with specs!")
    throw .unexpectedToken(String(remaining.prefix(1)))
  }


  private func match(_ regex: Regex<Substring>, in input: String) -> String? {
    guard let result = input.firstMatch(of: regex) else {
      return nil
    }
    let matched = String(result.output)
    return matched
  }

  private func cursorPosition() -> Int {
    input.distance(from: input.startIndex, to: cursor)
  }
}
