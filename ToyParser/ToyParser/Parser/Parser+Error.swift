//
//  Parser+Error.swift
//  ToyParser
//
//  Created by Tao Xu on 3/15/26.
//

enum ParserError: Error, CustomStringConvertible {
    case unexpectedEndOfInput(expected: TokenType)
    case unexpectedToken(actual: TokenType, expected: TokenType)
    case unexpectedLiteralProduction

    var description: String {
        switch self {
        case .unexpectedEndOfInput(let expected):
            return "Unexpected end of input, expected: \(expected)"
        case .unexpectedToken(let actual, let expected):
            return "Unexpected token: \(actual), expected: \(expected)"
        case .unexpectedLiteralProduction:
            return "Literal: unexpected literal production"
        }
    }
}
